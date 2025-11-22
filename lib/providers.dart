import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'providers.g.dart';

// A simple StateProvider for a counter that can be modified.
final globalCounterProvider = StateProvider<int>((ref) => 0);

// A simple Provider for a read-only message.
final welcomeMessageProvider = Provider<String>(
  (ref) => 'Hello from a global provider!',
);


// An example of a generated provider using riverpod_annotation
@riverpod
String generatedMessage(GeneratedMessageRef ref) {
  return 'This is a generated global message!';
}
