import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_demo/repositories.dart';

class InjectedFruitListPage extends ConsumerWidget {
  const InjectedFruitListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the fruitListProvider to get the async value.
    final fruitList = ref.watch(fruitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Injected Fruit List'),
      ),
      // Use AsyncValue.when to handle loading, error, and data states.
      body: fruitList.when(
        data: (fruits) => ListView.builder(
          itemCount: fruits.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(fruits[index]),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
