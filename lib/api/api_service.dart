import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/board.dart';
import '../models/todo_item.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000'; // FastAPI server URL

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'username=$username&password=$password',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<User?> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<List<Board>> getBoards() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/boards/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load boards: ${response.body}');
    }
  }

  Future<Board?> getBoard(int boardId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/boards/$boardId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Board.fromJson(data);
    } else {
      throw Exception('Failed to load board: ${response.body}');
    }
  }

  Future<Board?> createBoard(String title) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/boards/'),
      headers: headers,
      body: json.encode({'title': title}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Board.fromJson(data);
    } else {
      throw Exception('Failed to create board: ${response.body}');
    }
  }

  Future<Board?> updateBoard(int boardId, String newTitle) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/boards/$boardId'),
      headers: headers,
      body: json.encode({'title': newTitle}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Board.fromJson(data);
    } else {
      throw Exception('Failed to update board: ${response.body}');
    }
  }

  Future<void> deleteBoard(int boardId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/boards/$boardId'),
      headers: headers,
    );

    if (response.statusCode != 204) { // 204 No Content is expected for successful deletion
      throw Exception('Failed to delete board: ${response.body}');
    }
  }

  Future<TodoItem?> createTodoItem(int boardId, String description) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/boards/$boardId/todos/'),
      headers: headers,
      body: json.encode({'description': description, 'completed': false}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return TodoItem.fromJson(data);
    } else {
      throw Exception('Failed to create todo item: ${response.body}');
    }
  }

  Future<TodoItem?> updateTodoItem(int boardId, int todoId, {String? description, bool? completed}) async {
    final headers = await _getAuthHeaders();
    final Map<String, dynamic> body = {};
    if (description != null) body['description'] = description;
    if (completed != null) body['completed'] = completed;

    final response = await http.put(
      Uri.parse('$_baseUrl/boards/$boardId/todos/$todoId'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return TodoItem.fromJson(data);
    } else {
      throw Exception('Failed to update todo item: ${response.body}');
    }
  }

  Future<void> deleteTodoItem(int boardId, int todoId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/boards/$boardId/todos/$todoId'),
      headers: headers,
    );

    if (response.statusCode != 204) { // 204 No Content is expected
      throw Exception('Failed to delete todo item: ${response.body}');
    }
  }
}