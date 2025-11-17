import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [ChangeNotifier]는 Flutter SDK에 포함된 간단한 상태 관리 클래스입니다.
/// 상태가 변경될 때 `notifyListeners()`를 호출하여 리스너에게 알립니다.
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 상태 변경을 리스너에게 알립니다.
  }
}

/// [ChangeNotifierProvider]는 [ChangeNotifier]를 Riverpod 위젯 트리와 통합하는 데 사용됩니다.
/// 기존 [ChangeNotifier]를 사용하는 코드베이스를 Riverpod으로 마이그레이션할 때 유용합니다.
///
/// 참고: 새로운 Riverpod 프로젝트에서는 일반적으로 [StateNotifierProvider]가 더 나은 선택으로 간주됩니다.
final counterChangeNotifierProvider = ChangeNotifierProvider<Counter>((ref) {
  return Counter();
});

/// [ChangeNotifierProviderExamplePage]는 [counterChangeNotifierProvider]를 사용하여 카운터 앱을 구현하는 화면입니다.
class ChangeNotifierProviderExamplePage extends ConsumerWidget {
  const ChangeNotifierProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch`를 사용하여 [Counter] 인스턴스를 가져옵니다.
    // `notifyListeners()`가 호출되면 이 위젯은 다시 빌드됩니다.
    final counter = ref.watch(counterChangeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChangeNotifier Provider Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${counter.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // `ref.read`를 사용하여 `increment` 메소드를 호출합니다.
        // `onPressed` 콜백에서는 상태를 읽기만 하므로 `read`를 사용하는 것이 좋습니다.
        onPressed: () => ref.read(counterChangeNotifierProvider).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
