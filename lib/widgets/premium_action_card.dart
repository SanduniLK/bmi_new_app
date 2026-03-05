import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class PremiumActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final int index;
  final VoidCallback onTap;

  const PremiumActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.index,
    required this.onTap,
  });

  @override
  State<PremiumActionCard> createState() => _PremiumActionCardState();
}

class _PremiumActionCardState extends State<PremiumActionCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) => _hoverController.reverse(),
        onTapCancel: () => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _pulseController]),
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + _hoverController.value * 0.02,
              child: Container(
                decoration: BoxDecoration(
                  // White background
                  color: Colors.white,
                  // Gradient border only
                  border: Border.all(
                    width: 2,
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.gradient.colors.first as Color).withValues(alpha: 0.15),
                      blurRadius: 10 + _hoverController.value * 5,
                      offset: Offset(0, 5 + _hoverController.value * 3),
                    ),
                  ],
                  // Gradient border using gradient
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white,
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18), // Slightly smaller to show border
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // Colored edge/gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                            ),
                          ),
                        ),
                        
                        // White background with opacity to show gradient edges
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        
                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon with gradient
                              ShaderMask(
                                shaderCallback: (bounds) => widget.gradient.createShader(bounds),
                                child: Icon(
                                  widget.icon,
                                  size: 32,
                                  color: Colors.white, // Will be replaced by gradient
                                ),
                              ).animate().shimmer(
                                duration: 2000.ms,
                                delay: (widget.index * 200).ms,
                                color: Colors.white70,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Title
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = widget.gradient.createShader(
                                      const Rect.fromLTWH(0, 0, 200, 50),
                                    ),
                                ),
                              ),
                              
                              const SizedBox(height: 2),
                              
                              // Subtitle
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}