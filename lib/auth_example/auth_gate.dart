import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_demo/auth_example/auth_provider.dart';
import 'package:flutter_application_demo/auth_example/login_page.dart';
import 'package:flutter_application_demo/auth_example/protected_page.dart';

class AuthGate extends HookConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: switch (authState) {
        AuthState.authenticated => const ProtectedPage(),
        AuthState.unauthenticated => const LoginPage(),
        AuthState.loading => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
