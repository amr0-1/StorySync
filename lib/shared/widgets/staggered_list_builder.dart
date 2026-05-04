import 'package:flutter/material.dart';

/// Wraps a single list/grid item with a staggered fade+slide-up entry animation.
///
/// Each item fades in and slides up slightly with a delay based on its [index].
/// Delay is 40ms × index, capped at index 12 to avoid excessive delays.
/// Animation plays once on first build (not on rebuilds).
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;

  /// Duration of the fade+slide animation per item.
  final Duration duration;

  /// Per-item stagger delay.
  final Duration staggerDelay;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 40),
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Calculate stagger delay, capped at index 12
    final cappedIndex = widget.index.clamp(0, 12);
    final delay = widget.staggerDelay * cappedIndex;

    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
