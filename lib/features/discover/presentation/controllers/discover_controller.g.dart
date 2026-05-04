// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$discoverControllerHash() =>
    r'8b93383c553cd9da3adc25bb358eb47385b45fcc';

/// Controller for the Discover/Search feature.
///
/// Manages search state and communicates with the MangaDex API
/// to fetch manga search results.
///
/// Copied from [DiscoverController].
@ProviderFor(DiscoverController)
final discoverControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      DiscoverController,
      List<MangaItem>
    >.internal(
      DiscoverController.new,
      name: r'discoverControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$discoverControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiscoverController = AutoDisposeAsyncNotifier<List<MangaItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
