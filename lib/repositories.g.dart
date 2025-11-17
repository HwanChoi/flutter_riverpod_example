// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fruitRepositoryHash() => r'46af048969709a7dd8bdd49f63c49401ed810703';

/// A provider that creates an instance of [FruitRepository].
/// This is where the repository is "provided".
///
/// Copied from [fruitRepository].
@ProviderFor(fruitRepository)
final fruitRepositoryProvider = AutoDisposeProvider<FruitRepository>.internal(
  fruitRepository,
  name: r'fruitRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fruitRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FruitRepositoryRef = AutoDisposeProviderRef<FruitRepository>;
String _$fruitListHash() => r'6b1e89b25064bbb1a4926b59eb961e5a6bee3158';

/// A provider that fetches the list of fruits.
/// This provider "injects" the [FruitRepository] by watching [fruitRepositoryProvider].
///
/// Copied from [fruitList].
@ProviderFor(fruitList)
final fruitListProvider = AutoDisposeFutureProvider<List<String>>.internal(
  fruitList,
  name: r'fruitListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fruitListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FruitListRef = AutoDisposeFutureProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
