import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_demo/auth_repository.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the currently logged-in user.
    // We use .requireValue because this page should only be shown
    // when a user is logged in.
    final user = ref.watch(authControllerProvider).requireValue!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user.name}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('User ID: ${user.id}'),
          ],
        ),
      ),
    );
  }
}
