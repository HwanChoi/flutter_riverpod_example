class TodoItem {
  final int id;
  final String description;
  bool completed;
  final int boardId;

  TodoItem({
    required this.id,
    required this.description,
    required this.completed,
    required this.boardId,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      description: json['description'],
      completed: json['completed'],
      boardId: json['board_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'completed': completed,
      'board_id': boardId,
    };
  }

  TodoItem copyWith({
    int? id,
    String? description,
    bool? completed,
    int? boardId,
  }) {
    return TodoItem(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      boardId: boardId ?? this.boardId,
    );
  }
}
