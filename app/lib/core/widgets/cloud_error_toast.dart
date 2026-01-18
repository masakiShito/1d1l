import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CloudErrorToast {
  static void show(
    BuildContext context, {
    required String message,
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) {
      return;
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CloudToast(
        message: message,
        onDismissed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _CloudToast extends StatefulWidget {
  const _CloudToast({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_CloudToast> createState() => _CloudToastState();
}

class _CloudToastState extends State<_CloudToast>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _wobbleController;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  late final Animation<double> _scale;
  late final Animation<double> _wobble;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _opacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );
    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _wobble = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -1.5, end: 1.4),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: -1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -1.0, end: 0.6),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _wobbleController,
        curve: Curves.easeInOutSine,
      ),
    );

    _entryController.forward();
    _wobbleController.repeat(reverse: true);
    _autoDismiss();
  }

  Future<void> _autoDismiss() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    await _entryController.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _offset,
              child: ScaleTransition(
                scale: _scale,
                child: AnimatedBuilder(
                  animation: _wobble,
                  builder: (context, child) => Transform.rotate(
                    angle: _wobble.value * math.pi / 180,
                    child: child,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
