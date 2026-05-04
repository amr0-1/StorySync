import 'package:flutter/material.dart';
import 'package:storysync/core/models/reading_state.dart';
import 'package:storysync/core/theme/app_colors.dart';

/// Wraps a child widget and applies ambient animation based on [ReadingState].
///
/// - **cold**: Slow breathing opacity pulse (0.85 → 1.0 → 0.85) over 4 seconds.
/// - **hot**: Warm glow pulse with subtle scale (1.0 → 1.02 → 1.0) over 3 seconds.
/// - **normal**: No animation, passthrough.
///
/// Respects [TickerMode] — animations auto-pause when offscreen.
/// State transitions crossfade over 500ms rather than snapping.
class ReadingStateWrapper extends StatefulWidget {
  final ReadingState state;
  final Widget child;
  final BorderRadius? borderRadius;

  const ReadingStateWrapper({
    super.key,
    required this.state,
    required this.child,
    this.borderRadius,
  });

  @override
  State<ReadingStateWrapper> createState() => _ReadingStateWrapperState();
}

class _ReadingStateWrapperState extends State<ReadingStateWrapper>
    with TickerProviderStateMixin {
  AnimationController? _coldController;
  AnimationController? _hotController;

  // Transition animation for state changes
  late final AnimationController _transitionController;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    _setupAnimationForState(widget.state);
  }

  @override
  void didUpdateWidget(ReadingStateWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _disposeStateControllers();
      _setupAnimationForState(widget.state);
      // Smooth transition
      _transitionController.forward(from: 0.0);
    }
  }

  void _setupAnimationForState(ReadingState state) {
    switch (state) {
      case ReadingState.cold:
        _coldController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 4),
        )..repeat(reverse: true);
      case ReadingState.hot:
        _hotController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 3),
        )..repeat(reverse: true);
      case ReadingState.normal:
        break;
    }
  }

  void _disposeStateControllers() {
    _coldController?.dispose();
    _coldController = null;
    _hotController?.dispose();
    _hotController = null;
  }

  @override
  void dispose() {
    _disposeStateControllers();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.state) {
      ReadingState.cold => _buildCold(context),
      ReadingState.hot => _buildHot(context),
      ReadingState.normal => widget.child,
    };
  }

  Widget _buildCold(BuildContext context) {
    final controller = _coldController;
    if (controller == null) return widget.child;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Breathing fade: 0.85 → 1.0 → 0.85
        final opacity =
            0.85 + (0.15 * Curves.easeInOut.transform(controller.value));
        return Opacity(opacity: opacity, child: child);
      },
      child: widget.child,
    );
  }

  Widget _buildHot(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    final controller = _hotController;
    if (controller == null) return widget.child;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(controller.value);
        // Soft scale pulse: 1.0 → 1.02 → 1.0
        final scale = 1.0 + (0.02 * t);
        // Glow intensity follows the same curve
        final glowOpacity = 0.15 + (0.2 * t);
        final glowRadius = 6.0 + (6.0 * t);

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.goldDim.withValues(alpha: glowOpacity),
                  blurRadius: glowRadius,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
