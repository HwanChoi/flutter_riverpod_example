import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../api/api_service.dart';
import '../models/todo_item.dart';
import '../providers/auth_provider.dart'; // Import apiServiceProvider

class TodoListScreen extends ConsumerWidget {
  final int boardId;

  const TodoListScreen({Key? key, required this.boardId}) : super(key: key);

  Future<void> _showCreateTodoDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Todo'),
          content: TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Todo Description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.isNotEmpty) {
                  ref.read(boardProvider(boardId).notifier).addTodo(descriptionController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTodoDialog(BuildContext context, WidgetRef ref, TodoItem todo) async {
    final TextEditingController descriptionController = TextEditingController(text: todo.description);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Todo Description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (descriptionController.text.isNotEmpty && descriptionController.text != todo.description) {
                  try {
                    await ref.read(apiServiceProvider).updateTodoItem(boardId, todo.id, description: descriptionController.text);
                    ref.invalidate(boardProvider(boardId)); // Refresh the board details
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update todo: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsyncValue = ref.watch(boardProvider(boardId));

    return Scaffold(
      appBar: AppBar(
        title: boardAsyncValue.when(
          data: (board) => Text(board?.title ?? 'Todo Items'),
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Error'),
        ),
      ),
      body: boardAsyncValue.when(
        data: (board) {
          if (board == null || board.todos.isEmpty) {
            return const Center(child: Text('No todo items yet. Add one!'));
          }
          return ListView.builder(
            itemCount: board.todos.length,
            itemBuilder: (context, index) {
              final todo = board.todos[index];
              return Dismissible(
                key: Key(todo.id.toString()), // Unique key for Dismissible
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  ref.read(boardProvider(boardId).notifier).deleteTodo(todo.id);
                },
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      todo.description,
                      style: TextStyle(
                        decoration: todo.completed ? TextDecoration.lineThrough : null,
                        color: todo.completed ? Colors.grey : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: todo.completed,
                      onChanged: (bool? value) {
                        if (value != null) {
                          ref.read(boardProvider(boardId).notifier).updateTodoStatus(todo.id, value);
                        }
                      },
                    ),
                    onTap: () => _showEditTodoDialog(context, ref, todo),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTodoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}