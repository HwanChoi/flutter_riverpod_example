import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fruit_list_page.g.dart';

@riverpod
List<String> fruitList(FruitListRef ref) {
  return List<String>.generate(100, (index) => 'Fruit ${index + 1}');
}

class FruitListPage extends HookConsumerWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruits = ref.watch(fruitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit List'),
      ),
      body: ListView.builder(
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(fruits[index]),
          );
        },
      ),
    );
  }
}
