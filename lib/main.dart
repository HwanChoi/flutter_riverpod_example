import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_demo/auth/auth_gate.dart';
import 'package:flutter_application_demo/screens/register_screen.dart';
import 'package:flutter_application_demo/screens/login_screen.dart';
import 'package:flutter_application_demo/screens/board_list_screen.dart';
import 'package:flutter_application_demo/screens/todo_list_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TodoFlow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/boards': (context) => const BoardListScreen(),
        '/todos': (context) => TodoListScreen(boardId: ModalRoute.of(context)!.settings.arguments as int),
      },
    );
  }
}
