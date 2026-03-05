import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class FlowingWaterBackground extends StatelessWidget {
  final AnimationController flowController;
  final double progress;

  const FlowingWaterBackground({
    super.key,
    required this.flowController,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primaryLight,
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Main bottom wave - full screen width
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 80),
                  painter: _BottomWavePainter(
                    color: Colors.white.withValues(alpha: 0.15),
                    waveOffset: flowController.value,
                  ),
                ),
              ),
              
              // Secondary bottom wave - for depth
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 60),
                  painter: _BottomWavePainter(
                    color: Colors.white.withValues(alpha: 0.1),
                    waveOffset: flowController.value + 0.5,
                  ),
                ),
              ),
              
              // 💧 FALLING WATER DROPS - Animated from top to bottom
              ...List.generate(25, (index) {
                final randomX = (index * 23) % 100 / 100;
                final randomDelay = index * 0.1;
                final dropSize = (index % 4 + 2) * 1.5;
                final dropSpeed = 0.5 + (index % 3) * 0.2;
                
                // Calculate position based on animation value
                final dropPosition = (flowController.value * 2 + randomDelay) % 1.0;
                
                return Positioned(
                  left: MediaQuery.of(context).size.width * randomX,
                  top: MediaQuery.of(context).size.height * dropPosition - 20,
                  child: Opacity(
                    opacity: 0.4 * (1 - dropPosition), // Fade out as they fall
                    child: Transform.rotate(
                      angle: pi / 4, // Slight rotation for realistic drop shape
                      child: Container(
                        width: dropSize,
                        height: dropSize * 2, // Elongated drop shape
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.8),
                              Colors.white.withValues(alpha: 0.3),
                            ],
                          ),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(dropSize),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              // 💧 SPARKLING DROPS - Small drops that shimmer
              ...List.generate(15, (index) {
                final randomX = (index * 37) % 100 / 100;
                final randomY = (index * 53) % 100 / 100;
                final size = (index % 3 + 1) * 1.5;
                final twinkle = sin(flowController.value * 10 + index).abs();
                
                return Positioned(
                  left: MediaQuery.of(context).size.width * randomX,
                  top: MediaQuery.of(context).size.height * randomY,
                  child: Opacity(
                    opacity: 0.2 * twinkle,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              // 💧 BOTTOM SPLASH DROPS - Drops collecting at bottom
              ...List.generate(12, (index) {
                final randomX = (index * 29) % 100 / 100;
                final randomOffset = sin(flowController.value * 5 + index) * 5;
                
                return Positioned(
                  left: MediaQuery.of(context).size.width * randomX + randomOffset,
                  bottom: 10 + (index % 5) * 3.0,
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: 3,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.6),
                            Colors.white.withValues(alpha: 0.2),
                          ],
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  final Color color;
  final double waveOffset;

  _BottomWavePainter({required this.color, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Start from left edge
    path.moveTo(0, size.height);
    
    // Create waves across the full width
    for (double x = 0; x <= size.width; x += 15) {
      path.lineTo(
        x,
        size.height - 20 + // base position
        (12) * sin((x / 40 + waveOffset) * 3 * pi), // wave amplitude
      );
    }
    
    // Complete the path to the right edge and back
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}