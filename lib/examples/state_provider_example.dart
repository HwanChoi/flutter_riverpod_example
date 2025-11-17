
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [StateProvider]는 간단한 상태(예: 숫자, 문자열, bool)를 관리하고
/// 외부에서 그 상태를 수정할 수 있도록 할 때 사용됩니다.
///
/// 이 예제에서는 정수 카운터 값을 관리하는 provider를 생성합니다.
/// 초기값은 0입니다.
final counterProvider = StateProvider<int>((ref) {
  // 이 provider는 초기 상태로 0을 가집니다.
  return 0;
});

/// [StateProviderExamplePage]는 [counterProvider]를 사용하여 카운터 앱을 구현한 화면입니다.
class StateProviderExamplePage extends ConsumerWidget {
  const StateProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch`를 사용하여 `counterProvider`의 현재 상태(값)를 읽습니다.
    // provider의 상태가 변경되면 이 위젯은 자동으로 다시 빌드되어 UI를 업데이트합니다.
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StateProvider Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // `ref.read`를 사용하여 provider의 notifier에 접근하고 상태를 업데이트합니다.
          // `read`는 상태를 수신(listen)하지 않으므로, 버튼 클릭과 같은 이벤트 핸들러 내에서 사용하기에 적합합니다.
          // `.notifier`를 통해 `StateController`에 접근하고, `update` 메소드로 상태를 변경합니다.
          ref.read(counterProvider.notifier).update((state) => state + 1);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
