import 'package:flutter/material.dart';

class AnimatedFlame extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final Color? color;

  const AnimatedFlame({
    super.key,
    required this.controller,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + controller.value * 0.1,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Colors.orange).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: color ?? Colors.orange,
              size: size,
            ),
          ),
        );
      },
    );
  }
}