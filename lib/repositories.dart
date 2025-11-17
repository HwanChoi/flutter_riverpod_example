import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repositories.g.dart';

/// A repository for fetching fruit data.
class FruitRepository {
  /// Fetches a list of fruits.
  Future<List<String>> getFruits() async {
    // Simulate a network request.
    await Future.delayed(const Duration(seconds: 1));
    return ['Apple', 'Banana', 'Orange', 'Mango', 'Pineapple'];
  }
}

/// A provider that creates an instance of [FruitRepository].
/// This is where the repository is "provided".
@riverpod
FruitRepository fruitRepository(FruitRepositoryRef ref) {
  return FruitRepository();
}

/// A provider that fetches the list of fruits.
/// This provider "injects" the [FruitRepository] by watching [fruitRepositoryProvider].
@riverpod
Future<List<String>> fruitList(FruitListRef ref) {
  // Get the repository instance from the provider.
  final repository = ref.watch(fruitRepositoryProvider);
  // Fetch the fruits using the repository.
  return repository.getFruits();
}
