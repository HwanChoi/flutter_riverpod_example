
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Todo 모델 클래스
@immutable
class Todo {
  const Todo({required this.id, required this.description, required this.completed});
  final String id;
  final String description;
  final bool completed;

  Todo copyWith({String? id, String? description, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

/// [StateNotifier]는 불변(immutable) 상태를 관리하는 클래스입니다.
/// 상태를 직접 수정하는 대신, 새로운 상태 객체를 생성하여 상태를 업데이트합니다.
/// 복잡한 로직을 캡슐화하는 데 유용합니다.
class TodoNotifier extends StateNotifier<List<Todo>> {
  // 초기 상태를 `super` 생성자에 전달합니다.
  TodoNotifier() : super([]);

  /// 새로운 Todo 항목을 목록에 추가하는 메소드
  void addTodo(String description) {
    // 상태는 불변이므로, 기존 목록을 복사하고 새 항목을 추가하여 새 목록을 만듭니다.
    state = [
      ...state,
      Todo(
        id: DateTime.now().toIso8601String(),
        description: description,
        completed: false,
      ),
    ];
  }

  /// Todo 항목을 제거하는 메소드
  void removeTodo(String todoId) {
    state = state.where((todo) => todo.id != todoId).toList();
  }

  /// Todo 항목의 완료 상태를 토글하는 메소드
  void toggle(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id == todoId)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }
}

/// [StateNotifierProvider]는 [StateNotifier]의 인스턴스를 생성하고 제공합니다.
/// UI는 이 provider를 통해 notifier의 상태를 수신하고, notifier의 메소드를 호출하여 상태를 변경할 수 있습니다.
final todoNotifierProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});


/// [StateNotifierProviderExamplePage]는 Todo 목록을 보여주는 화면입니다.
class StateNotifierProviderExamplePage extends ConsumerWidget {
  const StateNotifierProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `ref.watch`를 사용하여 Todo 목록의 현재 상태를 가져옵니다.
    final todos = ref.watch(todoNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StateNotifierProvider Example'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(
              todo.description,
              style: TextStyle(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            leading: Checkbox(
              value: todo.completed,
              onChanged: (value) {
                // `ref.read`와 `.notifier`를 사용하여 notifier의 메소드를 호출합니다.
                ref.read(todoNotifierProvider.notifier).toggle(todo.id);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(todoNotifierProvider.notifier).removeTodo(todo.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final description = await _showAddTodoDialog(context);
          if (description != null && description.isNotEmpty) {
            ref.read(todoNotifierProvider.notifier).addTodo(description);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddTodoDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
