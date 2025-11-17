import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_demo/repositories/auth_repository.dart';

part 'providers.g.dart';

// A simple StateProvider for a counter that can be modified.
final globalCounterProvider = StateProvider<int>((ref) => 0);

// A simple Provider for a read-only message.
final welcomeMessageProvider = Provider<String>(
  (ref) => 'Hello from a global provider!',
);

// Provider for the AuthRepository. This creates and provides a single instance.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

// An example of a generated provider using riverpod_annotation
@riverpod
String generatedMessage(GeneratedMessageRef ref) {
  return 'This is a generated global message!';
}
