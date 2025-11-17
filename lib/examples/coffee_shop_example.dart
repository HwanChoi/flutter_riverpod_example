
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 모델 정의 (Entities)
// -------------------------------------------------

/// 커피 재료를 나타내는 열거형
enum CoffeeIngredient {
  beans('원두'),
  water('물'),
  milk('우유');

  const CoffeeIngredient(this.name);
  final String name;
}

/// 만들어진 커피를 나타내는 클래스
@immutable
class Coffee {
  const Coffee({required this.name, required this.ingredients});
  final String name;
  final List<CoffeeIngredient> ingredients;

  @override
  String toString() {
    return '$name (${ingredients.map((e) => e.name).join(', ')})';
  }
}

/// 고객의 주문을 나타내는 클래스
@immutable
class Order {
  const Order({required this.coffeeName});
  final String coffeeName;
}


// 2. 저장소 및 서비스 정의 (Abstractions and Services)
// -------------------------------------------------

/// 커피 재료를 관리하는 저장소 클래스입니다.
/// 실제 앱에서는 데이터베이스나 외부 API와 통신할 수 있습니다.
class CoffeeRepository {
  /// 특정 커피에 필요한 재료를 가져오는 메소드 (가상)
  Future<List<CoffeeIngredient>> getIngredientsFor(String coffeeName) async {
    // 실제 재료를 가져오는 것처럼 보이게 하기 위해 약간의 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 500));
    switch (coffeeName) {
      case '에스프레소':
        return [CoffeeIngredient.beans, CoffeeIngredient.water];
      case '라떼':
        return [CoffeeIngredient.beans, CoffeeIngredient.water, CoffeeIngredient.milk];
      default:
        throw Exception('$coffeeName 은(는) 없는 메뉴입니다.');
    }
  }
}

/// 바리스타의 역할을 하는 서비스 클래스입니다.
/// 커피를 만드는 비즈니스 로직을 담당합니다.
class BaristaService {
  // 생성자를 통해 `CoffeeRepository`를 의존성으로 주입받습니다.
  const BaristaService(this._repository);
  final CoffeeRepository _repository;

  /// 주문을 받아 커피를 만드는 메소드
  Future<Coffee> brewCoffee(Order order) async {
    print('바리스타: "${order.coffeeName}" 주문을 받았습니다. 재료를 확인합니다.');
    // 주입된 저장소를 사용하여 재료를 가져옵니다.
    final ingredients = await _repository.getIngredientsFor(order.coffeeName);
    print('바리스타: 재료(${ingredients.map((e) => e.name).join(', ')})를 준비했습니다. 커피를 만듭니다...');

    // 커피를 만드는 데 시간이 걸리는 것을 시뮬레이션합니다.
    await Future.delayed(const Duration(seconds: 2));

    print('바리스타: "${order.coffeeName}"가 완성되었습니다.');
    return Coffee(name: order.coffeeName, ingredients: ingredients);
  }
}


// 3. Riverpod Provider 설정 (Dependency Injection)
// -------------------------------------------------

/// [CoffeeRepository]의 인스턴스를 제공하는 Provider입니다.
/// 이 provider는 앱 전체에서 단 하나의 `CoffeeRepository` 인스턴스를 공유하게 해줍니다.
final coffeeRepositoryProvider = Provider<CoffeeRepository>((ref) {
  return CoffeeRepository();
});

/// [BaristaService]의 인스턴스를 제공하는 Provider입니다.
///
/// 이 provider는 `ref.watch`를 사용하여 `coffeeRepositoryProvider`를 읽고,
/// 그 결과(CoffeeRepository 인스턴스)를 `BaristaService`의 생성자에 전달합니다.
/// 이것이 바로 "의존성 주입"입니다. `BaristaService`는 자신이 사용할 `CoffeeRepository`를
/// 직접 생성하지 않고, 외부(Riverpod)로부터 제공받습니다.
final baristaServiceProvider = Provider<BaristaService>((ref) {
  final repository = ref.watch(coffeeRepositoryProvider);
  return BaristaService(repository);
});

/// 주문 처리 상태를 관리하는 Notifier입니다.
/// `AsyncValue`를 사용하여 로딩, 데이터, 에러 상태를 쉽게 처리할 수 있습니다.
class CoffeeOrderNotifier extends StateNotifier<AsyncValue<Coffee?>> {
  CoffeeOrderNotifier(this._baristaService) : super(const AsyncValue.data(null));

  final BaristaService _baristaService;

  /// 고객이 커피를 주문하는 액션
  Future<void> placeOrder(String coffeeName) async {
    // 상태를 로딩 중으로 설정하여 UI가 업데이트되도록 합니다.
    state = const AsyncValue.loading();
    try {
      // 바리스타 서비스를 호출하여 커피를 만듭니다.
      final coffee = await _baristaService.brewCoffee(Order(coffeeName: coffeeName));
      // 성공적으로 커피가 만들어지면 상태를 데이터로 업데이트합니다.
      state = AsyncValue.data(coffee);
    } catch (e, s) {
      // 에러가 발생하면 상태를 에러로 업데이트합니다.
      state = AsyncValue.error(e, s);
    }
  }

  /// 새로운 주문을 위해 상태를 초기화합니다.
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// [CoffeeOrderNotifier]를 제공하는 StateNotifierProvider입니다.
///
/// 이 provider 또한 `baristaServiceProvider`를 읽어서 `CoffeeOrderNotifier`에
/// `BaristaService` 인스턴스를 주입합니다.
final coffeeOrderProvider = StateNotifierProvider<CoffeeOrderNotifier, AsyncValue<Coffee?>>((ref) {
  final baristaService = ref.watch(baristaServiceProvider);
  return CoffeeOrderNotifier(baristaService);
});


// 4. UI (User Interface)
// -------------------------------------------------

class CoffeeShopPage extends ConsumerWidget {
  const CoffeeShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `coffeeOrderProvider`를 수신하여 주문 처리 상태에 따라 UI를 업데이트합니다.
    final orderState = ref.watch(coffeeOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DI Coffee Shop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상태에 따라 다른 위젯을 보여줍니다.
            orderState.when(
              // 데이터가 있는 경우 (커피가 완성되었거나, 아직 주문 전)
              data: (coffee) {
                if (coffee == null) {
                  // 아직 주문 전 상태
                  return Column(
                    children: [
                      const Text('무엇을 주문하시겠어요?', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Notifier의 메소드를 호출하여 주문을 시작합니다.
                          ref.read(coffeeOrderProvider.notifier).placeOrder('에스프레소');
                        },
                        child: const Text('에스프레소 주문'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(coffeeOrderProvider.notifier).placeOrder('라떼');
                        },
                        child: const Text('라떼 주문'),
                      ),
                    ],
                  );
                } else {
                  // 커피가 완성된 상태
                  return Column(
                    children: [
                      Text('주문하신 ${coffee.name} 나왔습니다!', style: const TextStyle(fontSize: 24)),
                      Text('재료: ${coffee.ingredients.map((e) => e.name).join(', ')}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // 상태를 초기화하여 다시 주문할 수 있게 합니다.
                          ref.read(coffeeOrderProvider.notifier).clear();
                        },
                        child: const Text('새로 주문하기'),
                      ),
                    ],
                  );
                }
              },
              // 로딩 중인 경우
              loading: () => const Column(
                children: [
                  Text('바리스타가 커피를 만들고 있습니다...', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
              // 에러가 발생한 경우
              error: (error, stackTrace) => Column(
                children: [
                  Text('죄송합니다. 오류가 발생했습니다: $error', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(coffeeOrderProvider.notifier).clear();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
