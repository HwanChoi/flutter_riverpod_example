import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async_fruit_list_page.g.dart';

@riverpod
Future<List<String>> asyncFruitList(AsyncFruitListRef ref, int page) async {
  // Simulate network request
  await Future.delayed(const Duration(seconds: 2));
  // You can also throw an exception to see the error state
  // throw Exception('Failed to load fruits');
  final start = page * 20;
  return List<String>.generate(20, (index) => 'Async Fruit ${start + index + 1}');
}

@riverpod
class FruitPages extends _$FruitPages {
  @override
  Future<List<String>> build() async {
    return ref.read(asyncFruitListProvider(0).future);
  }

  Future<void> fetchNextPage() async {
    ref.read(isFetchingNextPageProvider.notifier).state = true;
    final page = (state.value?.length ?? 0) ~/ 20;
    state = await AsyncValue.guard(() async {
      final nextPage = await ref.read(asyncFruitListProvider(page + 1).future);
      return [...state.value!, ...nextPage];
    });
    ref.read(isFetchingNextPageProvider.notifier).state = false;
  }
}

final isFetchingNextPageProvider = StateProvider<bool>((ref) => false);

class AsyncFruitListPage extends HookConsumerWidget {
  const AsyncFruitListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruits = ref.watch(fruitPagesProvider);
    final isFetchingNextPage = ref.watch(isFetchingNextPageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Fruit List'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter == 0) {
            ref.read(fruitPagesProvider.notifier).fetchNextPage();
          }
          return false;
        },
        child: fruits.when(
          data: (data) => RefreshIndicator(
            onRefresh: () => ref.refresh(fruitPagesProvider.future),
            child: ListView.builder(
              itemCount: data.length + (isFetchingNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == data.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListTile(
                  title: Text(data[index]),
                );
              },
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
