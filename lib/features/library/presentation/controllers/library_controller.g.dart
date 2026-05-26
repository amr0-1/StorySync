// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$libraryByStatusHash() => r'5638eeb2c5b87aa1b3dc1e7c9e7205ff2f6db56f';

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

/// StreamProvider that watches manga filtered by a specific reading status.
///
/// Usage:
/// ```dart
/// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
/// ```
///
/// Copied from [libraryByStatus].
@ProviderFor(libraryByStatus)
const libraryByStatusProvider = LibraryByStatusFamily();

/// StreamProvider that watches manga filtered by a specific reading status.
///
/// Usage:
/// ```dart
/// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
/// ```
///
/// Copied from [libraryByStatus].
class LibraryByStatusFamily extends Family<AsyncValue<List<MangaItem>>> {
  /// StreamProvider that watches manga filtered by a specific reading status.
  ///
  /// Usage:
  /// ```dart
  /// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
  /// ```
  ///
  /// Copied from [libraryByStatus].
  const LibraryByStatusFamily();

  /// StreamProvider that watches manga filtered by a specific reading status.
  ///
  /// Usage:
  /// ```dart
  /// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
  /// ```
  ///
  /// Copied from [libraryByStatus].
  LibraryByStatusProvider call(
    ReadingStatus status,
  ) {
    return LibraryByStatusProvider(
      status,
    );
  }

  @override
  LibraryByStatusProvider getProviderOverride(
    covariant LibraryByStatusProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'libraryByStatusProvider';
}

/// StreamProvider that watches manga filtered by a specific reading status.
///
/// Usage:
/// ```dart
/// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
/// ```
///
/// Copied from [libraryByStatus].
class LibraryByStatusProvider
    extends AutoDisposeStreamProvider<List<MangaItem>> {
  /// StreamProvider that watches manga filtered by a specific reading status.
  ///
  /// Usage:
  /// ```dart
  /// final readingManga = ref.watch(libraryByStatusProvider(ReadingStatus.reading));
  /// ```
  ///
  /// Copied from [libraryByStatus].
  LibraryByStatusProvider(
    ReadingStatus status,
  ) : this._internal(
          (ref) => libraryByStatus(
            ref as LibraryByStatusRef,
            status,
          ),
          from: libraryByStatusProvider,
          name: r'libraryByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$libraryByStatusHash,
          dependencies: LibraryByStatusFamily._dependencies,
          allTransitiveDependencies:
              LibraryByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  LibraryByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final ReadingStatus status;

  @override
  Override overrideWith(
    Stream<List<MangaItem>> Function(LibraryByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LibraryByStatusProvider._internal(
        (ref) => create(ref as LibraryByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MangaItem>> createElement() {
    return _LibraryByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LibraryByStatusRef on AutoDisposeStreamProviderRef<List<MangaItem>> {
  /// The parameter `status` of this provider.
  ReadingStatus get status;
}

class _LibraryByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<MangaItem>>
    with LibraryByStatusRef {
  _LibraryByStatusProviderElement(super.provider);

  @override
  ReadingStatus get status => (origin as LibraryByStatusProvider).status;
}

String _$libraryControllerHash() => r'cc823372e08f9295bcc4f2e2c2dc67fa46e31222';

/// Controller for the Library feature.
///
/// Provides a reactive stream of manga items from the local Isar database
/// and exposes methods for CRUD operations.
///
/// Copied from [LibraryController].
@ProviderFor(LibraryController)
final libraryControllerProvider = AutoDisposeStreamNotifierProvider<
    LibraryController, List<MangaItem>>.internal(
  LibraryController.new,
  name: r'libraryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryController = AutoDisposeStreamNotifier<List<MangaItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
