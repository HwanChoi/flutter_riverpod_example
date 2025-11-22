import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../providers/auth_provider.dart'; // For apiServiceProvider
import 'board_provider.dart'; // Import to access boardListProvider

class BoardNotifier extends FamilyAsyncNotifier<Board?, int> {
  @override
  FutureOr<Board?> build(int arg) async {
    final apiService = ref.watch(apiServiceProvider);
    return apiService.getBoard(arg);
  }

  Future<void> addTodo(String description) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      await apiService.createTodoItem(arg, description);
      // After creating, invalidate to refetch the whole board with the new item.
      ref.invalidateSelf();
      ref.invalidate(boardListProvider); // Invalidate the list
    } catch (e) {
      // Error handling can be added here if needed (e.g., showing a toast)
    }
  }

  Future<void> updateTodoStatus(int todoId, bool completed) async {
    final apiService = ref.read(apiServiceProvider);

    // Optimistic update

    state = await AsyncValue.guard(() async {
      final oldBoard = state.value;
      if (oldBoard == null) return null;

      final newTodos = oldBoard.todos.map((t) {
        return t.id == todoId ? t.copyWith(completed: completed) : t;
      }).toList();
      return oldBoard.copyWith(todos: newTodos);
    });

    // Call backend and revert on error by refetching
    try {
      await apiService.updateTodoItem(arg, todoId, completed: completed);
      ref.invalidate(boardListProvider); // Invalidate the list
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteTodo(int todoId) async {
    final apiService = ref.read(apiServiceProvider);

    // Optimistic update
    state = await AsyncValue.guard(() async {
      final oldBoard = state.value;
      if (oldBoard == null) return null;

      final newTodos = oldBoard.todos.where((t) => t.id != todoId).toList();
      return oldBoard.copyWith(todos: newTodos);
    });

    // Call backend and revert on error by refetching
    try {
      await apiService.deleteTodoItem(arg, todoId);
      ref.invalidate(boardListProvider); // Invalidate the list
    } catch (e) {
      ref.invalidateSelf();
    }
  }
}

final boardProvider = AsyncNotifierProvider.family<BoardNotifier, Board?, int>(
  BoardNotifier.new,
);
