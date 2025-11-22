class User {
  final int id;
  final String username;
  final bool isActive;

  User({required this.id, required this.username, required this.isActive});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'is_active': isActive,
    };
  }
}
