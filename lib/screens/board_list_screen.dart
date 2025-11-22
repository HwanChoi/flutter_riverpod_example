import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/board_provider.dart';
import '../providers/auth_provider.dart';
import '../api/api_service.dart';
import '../models/board.dart';
import 'todo_list_screen.dart'; // Import TodoListScreen

class BoardListScreen extends ConsumerWidget {
  const BoardListScreen({Key? key}) : super(key: key);

  Future<void> _showCreateBoardDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController titleController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Board'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Board Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  try {
                    await ref.read(apiServiceProvider).createBoard(titleController.text);
                    ref.invalidate(boardListProvider); // Refresh the board list
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create board: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDeleteBoardSheet(BuildContext context, WidgetRef ref, Board board) async {
    final TextEditingController titleController = TextEditingController(text: board.title);

    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'New Board Title'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isNotEmpty && titleController.text != board.title) {
                        try {
                          await ref.read(apiServiceProvider).updateBoard(board.id, titleController.text);
                          ref.invalidate(boardListProvider); // Refresh the board list
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update board: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Update'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(apiServiceProvider).deleteBoard(board.id);
                        ref.invalidate(boardListProvider); // Refresh the board list
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete board: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardListAsyncValue = ref.watch(boardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Boards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: boardListAsyncValue.when(
        data: (boards) {
          if (boards.isEmpty) {
            return const Center(child: Text('No boards yet. Create one!'));
          }
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(board.title),
                  subtitle: Text('${board.todos.length} todo items'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/todos', arguments: board.id);
                  },
                  onLongPress: () => _showEditDeleteBoardSheet(context, ref, board),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBoardDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}