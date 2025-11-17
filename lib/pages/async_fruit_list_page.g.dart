// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async_fruit_list_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$asyncFruitListHash() => r'46b98111f5a8a5953524c9709858de2ea7507004';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [asyncFruitList].
@ProviderFor(asyncFruitList)
const asyncFruitListProvider = AsyncFruitListFamily();

/// See also [asyncFruitList].
class AsyncFruitListFamily extends Family<AsyncValue<List<String>>> {
  /// See also [asyncFruitList].
  const AsyncFruitListFamily();

  /// See also [asyncFruitList].
  AsyncFruitListProvider call(
    int page,
  ) {
    return AsyncFruitListProvider(
      page,
    );
  }

  @override
  AsyncFruitListProvider getProviderOverride(
    covariant AsyncFruitListProvider provider,
  ) {
    return call(
      provider.page,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'asyncFruitListProvider';
}

/// See also [asyncFruitList].
class AsyncFruitListProvider extends AutoDisposeFutureProvider<List<String>> {
  /// See also [asyncFruitList].
  AsyncFruitListProvider(
    int page,
  ) : this._internal(
          (ref) => asyncFruitList(
            ref as AsyncFruitListRef,
            page,
          ),
          from: asyncFruitListProvider,
          name: r'asyncFruitListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$asyncFruitListHash,
          dependencies: AsyncFruitListFamily._dependencies,
          allTransitiveDependencies:
              AsyncFruitListFamily._allTransitiveDependencies,
          page: page,
        );

  AsyncFruitListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(AsyncFruitListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AsyncFruitListProvider._internal(
        (ref) => create(ref as AsyncFruitListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _AsyncFruitListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AsyncFruitListProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AsyncFruitListRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `page` of this provider.
  int get page;
}

class _AsyncFruitListProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with AsyncFruitListRef {
  _AsyncFruitListProviderElement(super.provider);

  @override
  int get page => (origin as AsyncFruitListProvider).page;
}

String _$fruitPagesHash() => r'89528c7cd63f0a5c932d631f139ca643d339fe27';

/// See also [FruitPages].
@ProviderFor(FruitPages)
final fruitPagesProvider =
    AutoDisposeAsyncNotifierProvider<FruitPages, List<String>>.internal(
  FruitPages.new,
  name: r'fruitPagesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fruitPagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FruitPages = AutoDisposeAsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
