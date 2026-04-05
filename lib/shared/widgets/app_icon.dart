import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';

/// Reusable app icon widget that adapts to different UI contexts.
class AppIcon extends StatelessWidget {
  static const String assetPath = 'assets/images/app_icon_v2.png';

  final double size;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final BoxFit fit;

  const AppIcon({
    super.key,
    this.size = 28,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.fit = BoxFit.cover,
  });

  const AppIcon.small({super.key})
    : size = 24,
      borderRadius = const BorderRadius.all(
        Radius.circular(AppDimensions.radiusXS),
      ),
      shape = BoxShape.rectangle,
      fit = BoxFit.cover;

  const AppIcon.medium({super.key})
    : size = 56,
      borderRadius = const BorderRadius.all(
        Radius.circular(AppDimensions.radiusSM),
      ),
      shape = BoxShape.rectangle,
      fit = BoxFit.cover;

  const AppIcon.large({super.key})
    : size = 100,
      borderRadius = const BorderRadius.all(
        Radius.circular(AppDimensions.radiusSM),
      ),
      shape = BoxShape.rectangle,
      fit = BoxFit.cover;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _FallbackIcon(
          size: size,
          shape: shape,
          borderRadius: borderRadius,
        );
      },
    );

    if (shape == BoxShape.circle) {
      image = ClipOval(child: image);
    } else {
      image = ClipRRect(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppDimensions.radiusXS),
        child: image,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
        border: Border.all(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final double size;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const _FallbackIcon({
    required this.size,
    required this.shape,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.inkPanel,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(AppDimensions.radiusXS)),
      ),
      child: Icon(
        Icons.auto_stories_rounded,
        size: size * 0.44,
        color: colors.goldLight,
      ),
    );
  }
}
