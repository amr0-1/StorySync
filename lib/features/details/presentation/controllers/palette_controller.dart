import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Palette provider
/// Key format: "<mangaDexId>|<coverUrl>"
final coverPaletteProvider = FutureProvider.family<Color?, String>((ref, key) async {
  final parts = key.split('|');
  final coverUrl = parts.length > 1 ? parts.sublist(1).join('|') : parts.first;

  // Prefer CachedNetworkImageProvider when available; fall back to NetworkImage
  ImageProvider imageProvider = CachedNetworkImageProvider(coverUrl);
  try {
    final palette = await PaletteGenerator.fromImageProvider(
      imageProvider,
      maximumColorCount: 20,
    );

    final Color? dominant = palette.dominantColor?.color;
    final Color? vibrant = palette.vibrantColor?.color;

    // Simple heuristic: prefer saturated dominantColor, else fall back to vibrantColor
    if (dominant != null) {
      final saturation = HSLColor.fromColor(dominant).saturation;
      if (saturation > 0.25) {
        return dominant;
      }
    }

    if (dominant == null && vibrant != null) {
      return vibrant;
    } else if (dominant != null && vibrant != null) {
      // If dominant exists but is low-saturation, prefer vibrant as a fallback
      return vibrant;
    }

    return dominant ?? vibrant;
  } catch (_) {
    // On error, gracefully attempt with NetworkImage
    imageProvider = NetworkImage(coverUrl);
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );
      final Color? dominant = palette.dominantColor?.color;
      final Color? vibrant = palette.vibrantColor?.color;
      return dominant ?? vibrant;
    } catch (_) {
      return null;
    }
  }
});
