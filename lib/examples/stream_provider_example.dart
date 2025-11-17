import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [StreamProvider]는 스트림을 수신하고 그 결과를 위젯에 제공하는 데 사용됩니다.
/// 실시간 데이터 업데이트, 예를 들어 채팅 메시지, 주식 시세 또는 주기적인 이벤트에 유용합니다.
///
/// 이 예제에서는 1초마다 숫자를 방출하는 스트림을 생성하는 provider를 만듭니다.
/// 스트림은 10개의 숫자를 방출한 후 닫힙니다.
final numberStreamProvider = StreamProvider<int>((ref) {
  // 1초 간격으로 1부터 시작하여 10개의 숫자를 방출하는 스트림을 반환합니다.
  return Stream.periodic(const Duration(seconds: 1), (i) => i + 1).take(10);
});

/// [StreamProviderExamplePage]는 [numberStreamProvider]를 사용하여 스트림의 최신 값을 표시하는 화면입니다.
class StreamProviderExamplePage extends ConsumerWidget {
  const StreamProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch`를 사용하여 스트림의 상태를 수신합니다.
    // `AsyncValue`는 데이터, 로딩, 오류 상태를 처리하는 데 도움이 됩니다.
    final stream = ref.watch(numberStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Provider Example'),
      ),
      body: Center(
        // `when` 메소드를 사용하여 스트림의 다른 상태에 따라 다른 UI를 렌더링합니다.
        child: stream.when(
          // 데이터가 성공적으로 수신되면 값을 표시합니다.
          data: (value) => Text(
            'Value: $value',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          // 스트림이 로딩 중일 때(첫 값을 기다릴 때) 로딩 인디케이터를 표시합니다.
          loading: () => const CircularProgressIndicator(),
          // 스트림에서 오류가 발생하면 오류 메시지를 표시합니다.
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
    );
  }
}
