import 'package:bmi_new_app/screens/water_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../utils/constants.dart';
 // Add this import

class WaterTrackerWidget extends StatefulWidget {
  const WaterTrackerWidget({super.key});

  @override
  State<WaterTrackerWidget> createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends State<WaterTrackerWidget> with TickerProviderStateMixin {
  int _currentGlasses = 0;
  final int _targetGlasses = 8;
  late AnimationController _waveController;
  late AnimationController _dropController;
  late Animation<double> _waveAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _waveAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentGlasses = prefs.getInt('water_intake') ?? 0;
    });
  }

  Future<void> _saveWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_intake', _currentGlasses);
  }

  void _addWater() {
    if (_currentGlasses < _targetGlasses) {
      setState(() {
        _currentGlasses++;
      });
      _saveWaterIntake();
      _dropController.forward(from: 0.0);
    }
  }

  void _resetWater() {
    setState(() {
      _currentGlasses = 0;
    });
    _saveWaterIntake();
  }

  double get _progress => _currentGlasses / _targetGlasses;

  @override
  void dispose() {
    _waveController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _resetWater,
                icon: const Icon(Icons.refresh, size: 20),
                color: Colors.grey,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Water Glass Visualization
          Stack(
            alignment: Alignment.center,
            children: [
              // Glass outline
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Stack(
                    children: [
                      // Water fill
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            height: 140 * _progress,
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryLight.withValues(alpha: 0.6),
                                  AppColors.primary,
                                ],
                              ),
                            ),
                            child: _progress > 0
                                ? CustomPaint(
                                    size: const Size(double.infinity, 20),
                                    painter: _WavePainter(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      waveOffset: _waveAnimation.value,
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                      
                      // Bubbles
                      ...List.generate(5, (index) {
                        return Positioned(
                          left: 20.0 + (index * 30),
                          bottom: 20.0 + (index * 15),
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, -_waveController.value * 5),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              // Water drops animation
              if (_dropController.isAnimating)
                Positioned(
                  top: 10,
                  child: Icon(
                    Icons.water_drop,
                    color: AppColors.primary,
                    size: 30,
                  ).animate(
                    controller: _dropController,
                  ).fadeOut().move(
                    begin: const Offset(0, -20),
                    end: const Offset(0, 50),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Glasses counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_currentGlasses of $_targetGlasses glasses',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _progress >= 0.75
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: _progress >= 0.75
                        ? AppColors.success
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Water glasses grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_targetGlasses, (index) {
              final isFilled = index < _currentGlasses;
              return GestureDetector(
                onTap: () {
                  if (index == _currentGlasses) {
                    _addWater();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  width: 30,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isFilled
                        ? LinearGradient(
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primary,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isFilled ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFilled
                          ? Colors.transparent
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isFilled
                      ? const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ).animate().scale(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: index * 50),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Motivational message
          Center(
            child: Text(
              _getMotivationalMessage(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔗 VIEW DETAILS BUTTON - Links to full water tracking page
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WaterTrackingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.water_drop, size: 18),
              label: const Text('View Detailed Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (_currentGlasses == 0) {
      return "💧 Start your hydration journey!";
    } else if (_currentGlasses < 4) {
      return "💪 You're doing great! Keep drinking!";
    } else if (_currentGlasses < 6) {
      return "🌟 Halfway there! You're awesome!";
    } else if (_currentGlasses < 8) {
      return "🎯 Almost at your goal! Finish strong!";
    } else {
      return "✨ Goal achieved! Stay hydrated!";
    }
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double waveOffset;

  _WavePainter({required this.color, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    
    for (double x = 0; x <= size.width; x += 10) {
      path.lineTo(
        x,
        size.height * 0.3 + 
        (size.height * 0.1) * sin((x / size.width + waveOffset) * 2 * pi),
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}