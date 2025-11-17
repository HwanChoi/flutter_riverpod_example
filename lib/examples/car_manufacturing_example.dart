
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 모델 정의 (Entities)
// -------------------------------------------------

/// 자동차 부품을 나타내는 클래스
@immutable
class CarPart {
  const CarPart(this.name);
  final String name;
}

// 구체적인 부품 클래스들
class Engine extends CarPart {
  const Engine() : super('엔진');
}

class Wheel extends CarPart {
  const Wheel() : super('바퀴');
}

class Chassis extends CarPart {
  const Chassis(this.model) : super('$model 차체');
  final String model;
}

/// 완성된 자동차를 나타내는 클래스
@immutable
class Car {
  const Car({required this.model, required this.parts});
  final String model;
  final List<CarPart> parts;

  @override
  String toString() {
    return '$model [${parts.map((p) => p.name).join(', ')}]';
  }
}

/// 조립 상태를 나타내는 열거형
enum AssemblyStatus {
  idle('대기 중'),
  fetchingChassis('차체 운반 중...'),
  fetchingEngine('엔진 운반 중...'),
  fetchingWheels('바퀴 운반 중...'),
  assembling('최종 조립 중...'),
  completed('완성');

  const AssemblyStatus(this.message);
  final String message;
}

/// 조립 라인의 현재 상태를 나타내는 클래스
@immutable
class AssemblyLineState {
  const AssemblyLineState({
    this.status = AssemblyStatus.idle,
    this.assembledParts = const [],
    this.finalCar,
  });

  final AssemblyStatus status;
  final List<CarPart> assembledParts;
  final Car? finalCar;

  AssemblyLineState copyWith({
    AssemblyStatus? status,
    List<CarPart>? assembledParts,
    Car? finalCar,
  }) {
    return AssemblyLineState(
      status: status ?? this.status,
      assembledParts: assembledParts ?? this.assembledParts,
      finalCar: finalCar ?? this.finalCar,
    );
  }
}


// 2. 부품 공급 업체 및 조립 라인 서비스 정의
// -------------------------------------------------

/// 각 부품 공급 업체는 독립적인 서비스로 간주됩니다.
class EngineSupplier {
  Future<Engine> getEngine() async {
    await Future.delayed(const Duration(seconds: 1));
    print('공급업체: 엔진을 공급했습니다.');
    return const Engine();
  }
}

class WheelSupplier {
  Future<List<Wheel>> getWheels() async {
    await Future.delayed(const Duration(seconds: 1));
    print('공급업체: 바퀴 4개를 공급했습니다.');
    return List.generate(4, (_) => const Wheel());
  }
}

class ChassisSupplier {
  Future<Chassis> getChassis(String model) async {
    await Future.delayed(const Duration(seconds: 1));
    print('공급업체: $model 차체를 공급했습니다.');
    return Chassis(model);
  }
}

/// 조립 라인 서비스입니다.
/// 여러 부품 공급 업체에 대한 의존성을 가집니다.
class AssemblyLineService {
  const AssemblyLineService({
    required this.engineSupplier,
    required this.wheelSupplier,
    required this.chassisSupplier,
  });

  // 생성자를 통해 여러 의존성을 주입받습니다.
  final EngineSupplier engineSupplier;
  final WheelSupplier wheelSupplier;
  final ChassisSupplier chassisSupplier;

  // 자동차 조립 과정을 스트림으로 반환하여 단계별 진행 상황을 알립니다.
  Stream<AssemblyLineState> assembleCar(String model) async* {
    final assembledParts = <CarPart>[];

    // 1. 차체 가져오기
    yield AssemblyLineState(status: AssemblyStatus.fetchingChassis);
    final chassis = await chassisSupplier.getChassis(model);
    assembledParts.add(chassis);
    yield AssemblyLineState(status: AssemblyStatus.fetchingChassis, assembledParts: List.from(assembledParts));

    // 2. 엔진 가져오기
    yield AssemblyLineState(status: AssemblyStatus.fetchingEngine, assembledParts: List.from(assembledParts));
    final engine = await engineSupplier.getEngine();
    assembledParts.add(engine);
    yield AssemblyLineState(status: AssemblyStatus.fetchingEngine, assembledParts: List.from(assembledParts));

    // 3. 바퀴 가져오기
    yield AssemblyLineState(status: AssemblyStatus.fetchingWheels, assembledParts: List.from(assembledParts));
    final wheels = await wheelSupplier.getWheels();
    assembledParts.addAll(wheels);
    yield AssemblyLineState(status: AssemblyStatus.fetchingWheels, assembledParts: List.from(assembledParts));

    // 4. 최종 조립
    yield AssemblyLineState(status: AssemblyStatus.assembling, assembledParts: List.from(assembledParts));
    await Future.delayed(const Duration(seconds: 2));
    final car = Car(model: model, parts: assembledParts);
    
    // 5. 완성
    yield AssemblyLineState(status: AssemblyStatus.completed, assembledParts: assembledParts, finalCar: car);
    print('조립 라인: $model 조립이 완료되었습니다!');
  }
}


// 3. Riverpod Provider 설정 (Dependency Injection)
// -------------------------------------------------

// 각 부품 공급 업체를 위한 독립적인 Provider들
final engineSupplierProvider = Provider((_) => EngineSupplier());
final wheelSupplierProvider = Provider((_) => WheelSupplier());
final chassisSupplierProvider = Provider((_) => ChassisSupplier());

/// [AssemblyLineService]를 위한 Provider입니다.
/// 여러 다른 Provider(`engineSupplierProvider` 등)를 읽어서
/// `AssemblyLineService`의 생성자에 의존성으로 주입합니다.
final assemblyLineProvider = Provider((ref) {
  return AssemblyLineService(
    engineSupplier: ref.watch(engineSupplierProvider),
    wheelSupplier: ref.watch(wheelSupplierProvider),
    chassisSupplier: ref.watch(chassisSupplierProvider),
  );
});

/// 자동차 조립 과정을 관리하는 Notifier
class CarAssemblyNotifier extends StateNotifier<AssemblyLineState> {
  CarAssemblyNotifier(this._assemblyLine) : super(const AssemblyLineState());

  final AssemblyLineService _assemblyLine;
  StreamSubscription? _subscription;

  Future<void> startAssembly(String model) async {
    // 이미 조립 중이면 중복 실행 방지
    if (state.status != AssemblyStatus.idle && state.status != AssemblyStatus.completed) return;

    // 이전 스트림 구독이 있다면 취소
    _subscription?.cancel();

    // 조립 라인 서비스의 스트림을 구독하여 상태가 변경될 때마다 UI를 업데이트
    _subscription = _assemblyLine.assembleCar(model).listen(
      (newState) {
        state = newState;
      },
      onDone: () {
        print('Notifier: 조립 스트림 완료.');
      },
      onError: (e) {
        print('Notifier: 오류 발생 - $e');
        // 여기서 에러 상태 처리 가능
      },
    );
  }

  void reset() {
    _subscription?.cancel();
    state = const AssemblyLineState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// [CarAssemblyNotifier]를 제공하는 StateNotifierProvider
final carAssemblyNotifierProvider = StateNotifierProvider<CarAssemblyNotifier, AssemblyLineState>((ref) {
  final assemblyLine = ref.watch(assemblyLineProvider);
  return CarAssemblyNotifier(assemblyLine);
});


// 4. UI (User Interface)
// -------------------------------------------------

class CarManufacturingPage extends ConsumerWidget {
  const CarManufacturingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(carAssemblyNotifierProvider);
    final notifier = ref.read(carAssemblyNotifierProvider.notifier);
    final bool isAssembling = state.status != AssemblyStatus.idle && state.status != AssemblyStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DI Car Factory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 조립 시작 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isAssembling ? null : () => notifier.startAssembly('세단'),
                  child: const Text('세단 만들기'),
                ),
                ElevatedButton(
                  onPressed: isAssembling ? null : () => notifier.startAssembly('SUV'),
                  child: const Text('SUV 만들기'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 현재 상태 디스플레이
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '조립 상태: ${state.status.message}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (isAssembling) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 조립된 부품 목록
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('현재까지 조립된 부품', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.assembledParts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.build_circle_outlined),
                              title: Text(state.assembledParts[index].name),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 최종 결과
            if (state.status == AssemblyStatus.completed && state.finalCar != null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '🎉 ${state.finalCar!.model} 완성! 🎉',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(state.finalCar.toString()),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => notifier.reset(),
                        child: const Text('새로 만들기'),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
