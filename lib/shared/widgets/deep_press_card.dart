import 'package:flutter/material.dart';
import 'package:storysync/core/utils/haptic_util.dart';

/// A wrapper that replaces default Material ripple with a premium
/// "deep press" scale-down + haptic feedback effect.
///
/// On press: scales to 0.97 over 100ms with haptic.
/// On release: rebounds to 1.0 over 150ms with easeOutBack curve.
class DeepPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DeepPressCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<DeepPressCard> createState() => _DeepPressCardState();
}

class _DeepPressCardState extends State<DeepPressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    StorySyncHaptics.lightTap();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
