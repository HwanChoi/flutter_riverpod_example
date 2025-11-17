import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 1. Provider for useConsumer example
final counterProvider = StateProvider((ref) => 0);

class HooksExamplesPage extends HookConsumerWidget {
  const HooksExamplesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. useState: Manages a simple counter state
    final counterState = useState(0);

    // 3. useEffect: Runs once after the first build
    useEffect(() {
      // This is similar to initState
      debugPrint('HooksExamplesPage: useEffect[] runs once');
      // You can perform initial setup here, like fetching data
      return () {
        // This is similar to dispose
        debugPrint('HooksExamplesPage: useEffect[] cleanup');
      };
    }, const []);

    // 4. useMemoized: Memoizes a complex calculation
    final expensiveValue = useMemoized(() {
      debugPrint('Running expensive calculation...');
      return List.generate(10000, (index) => index).reduce((a, b) => a + b);
    }, []);

    // 5. useRef: Creates a mutable reference that persists across builds
    final textEditingControllerRef = useRef(TextEditingController());

    // 6. useContext: Provides the BuildContext
    final buildContext = useContext();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Hooks Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. useState'),
            Text('Counter: ${counterState.value}'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => counterState.value++,
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => counterState.value = 0,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildSectionTitle('2. useMemoized'),
            Text('Expensive Calculation Result: $expensiveValue'),
            const Divider(height: 30),
            _buildSectionTitle('3. useRef'),
            TextField(
              controller: textEditingControllerRef.value,
              decoration: const InputDecoration(
                labelText: 'Type something',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(buildContext).showSnackBar(
                  SnackBar(
                    content: Text(
                        'From useRef: ${textEditingControllerRef.value.text}'),
                  ),
                );
              },
              child: const Text('Show Text from Ref'),
            ),
            const Divider(height: 30),
            _buildSectionTitle('4. useConsumer (hooks_riverpod)'),
            _buildRiverpodCounter(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRiverpodCounter(WidgetRef ref) {
    final riverpodCounter = ref.watch(counterProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riverpod Counter: $riverpodCounter'),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).state++,
              child: const Text('Increment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).state = 0,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
