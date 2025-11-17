import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_demo/auth_repository.dart';
import 'package:flutter_application_demo/pages/login_page.dart';
import 'package:flutter_application_demo/pages/user_profile_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state.
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) {
        // If the user is logged in, show the UserProfilePage.
        if (user != null) {
          return const UserProfilePage();
        }
        // Otherwise, show the LoginPage.
        return const LoginPage();
      },
      // Show a loading indicator while checking auth state.
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // Show an error message if something goes wrong.
      // In a real app, you might want to show the LoginPage
      // with an error message instead.
      error: (err, stack) => Scaffold(
        body: Center(child: Text('An error occurred: $err')),
      ),
    );
  }
}
