
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [Provider]는 변경되지 않는 간단한 값을 제공하는 데 사용됩니다.
/// 외부에서 주입된 의존성을 위젯 트리 내에서 쉽게 접근할 수 있게 해줍니다.
///
/// 이 예제에서는 "Hello from Simple Provider!" 라는 간단한 문자열 메시지를 제공하는 provider를 생성합니다.
/// 이 provider는 앱의 어느 위젯에서나 읽을 수 있습니다.
final simpleMessageProvider = Provider<String>((ref) {
  // 'ref' 객체는 다른 provider를 읽거나 provider의 생명주기를 관리하는 데 사용됩니다.
  // 여기서는 간단한 문자열 값을 반환합니다.
  return 'Hello from Simple Provider!';
});

/// [SimpleProviderExamplePage]는 [simpleMessageProvider]를 사용하여 메시지를 표시하는 화면입니다.
class SimpleProviderExamplePage extends ConsumerWidget {
  /// [ConsumerWidget]은 Riverpod의 provider를 수신(listen)할 수 있는 StatelessWidget입니다.
  /// `build` 메소드는 `WidgetRef` 객체를 추가로 받습니다.
  const SimpleProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch`를 사용하여 provider의 값을 읽고 변화를 감지합니다.
    // `simpleMessageProvider`의 값이 변경되면 이 위젯은 자동으로 다시 빌드됩니다.
    // (이 특정 provider는 값이 변경되지 않지만, `watch`는 일반적인 사용 패턴입니다.)
    final message = ref.watch(simpleMessageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Provider'),
      ),
      body: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
