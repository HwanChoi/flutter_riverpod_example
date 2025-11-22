import 'todo_item.dart';

class Board {
  final int id;
  final String title;
  final int ownerId;
  final List<TodoItem> todos;

  Board({required this.id, required this.title, required this.ownerId, required this.todos});

  factory Board.fromJson(Map<String, dynamic> json) {
    var todosList = json['todos'] as List;
    List<TodoItem> todos = todosList.map((i) => TodoItem.fromJson(i)).toList();

    return Board(
      id: json['id'],
      title: json['title'],
      ownerId: json['owner_id'],
      todos: todos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'owner_id': ownerId,
      'todos': todos.map((e) => e.toJson()).toList(),
    };
  }

  Board copyWith({
    int? id,
    String? title,
    int? ownerId,
    List<TodoItem>? todos,
  }) {
    return Board(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      todos: todos ?? this.todos,
    );
  }
}
