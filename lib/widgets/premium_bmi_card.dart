import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/bmi_record.dart';
import '../utils/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCharacterBMICard extends StatefulWidget {
  const AnimatedCharacterBMICard({super.key});

  @override
  State<AnimatedCharacterBMICard> createState() => _AnimatedCharacterBMICardState();
}

class _AnimatedCharacterBMICardState extends State<AnimatedCharacterBMICard> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _blinkController;
  late AnimationController _bounceController;
  late AnimationController _energyController;
  late Animation<double> _bounceAnimation;
  BMIRecord? _latestBMI;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _energyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutSine),
    );
    
    // Auto blink every 3 seconds
    Future.delayed(const Duration(seconds: 2), _startBlinking);
    
    _loadLatestBMI();
  }

  void _startBlinking() {
    if (mounted) {
      _blinkController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _blinkController.reverse();
          }
        });
      });
      
      Future.delayed(const Duration(seconds: 3), _startBlinking);
    }
  }

  Future<void> _loadLatestBMI() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final record = await firestoreService.getLatestBMIRecord();
    
    if (mounted) {
      setState(() {
        _latestBMI = record;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    _energyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerCard();
    }

    return _latestBMI == null ? _buildEmptyState() : _buildCharacterCard(_latestBMI!);
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/bmi-calculator'),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCharacterPreview('😟', 'Low'),
                  const SizedBox(width: 20),
                  _buildCharacterPreview('😊', 'Normal'),
                  const SizedBox(width: 20),
                  _buildCharacterPreview('😅', 'High'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Meet Your BMI Characters!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to calculate BMI',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterPreview(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(BMIRecord record) {
    final bmiValue = record.bmi;
    final characterType = _getCharacterType(bmiValue);
    final characterColor = _getCharacterColor(bmiValue);
    final characterData = _getCharacterData(bmiValue);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_idleController, _bounceController, _energyController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  characterColor,
                  characterColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: characterColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Character Container
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Character based on BMI type
                        if (characterType == 'underweight')
                          _buildUnderweightCharacter()
                        else if (characterType == 'normal')
                          _buildNormalCharacter()
                        else
                          _buildOverweightCharacter(),
                      ],
                    ),
                  ),
                  
                  // BMI Info Section - Perfectly aligned
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BMI Value Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              bmiValue.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'kg/m²',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Category and Type Row
                        Row(
                          children: [
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                record.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 10),
                            
                            // Character Type with Emoji
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    characterData['type'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    characterData['emoji'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Character Message
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            characterData['message'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnderweightCharacter() {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _UnderweightCharacterPainter(
            idleOffset: _idleController.value,
            isBlinking: _blinkController.value > 0.5,
            energyLevel: _energyController.value,
          ),
          size: const Size(100, 100),
        );
      },
    );
  }

  Widget _buildNormalCharacter() {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _NormalCharacterPainter(
            idleOffset: _idleController.value,
            isBlinking: _blinkController.value > 0.5,
            energyLevel: _energyController.value,
          ),
          size: const Size(100, 100),
        );
      },
    );
  }

  Widget _buildOverweightCharacter() {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _OverweightCharacterPainter(
            idleOffset: _idleController.value,
            isBlinking: _blinkController.value > 0.5,
            energyLevel: _energyController.value,
          ),
          size: const Size(100, 100),
        );
      },
    );
  }

  String _getCharacterType(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    return 'overweight';
  }

  Color _getCharacterColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF64B5F6); // Light Blue
    if (bmi < 25) return AppColors.primary; // Teal
    return const Color(0xFFFFA726); // Orange
  }

  Map<String, dynamic> _getCharacterData(double bmi) {
    if (bmi < 18.5) {
      return {
        'type': 'SLIM',
        'emoji': '😟',
        'message': 'Time to nourish! Need more energy 💪',
      };
    } else if (bmi < 25) {
      return {
        'type': 'FIT',
        'emoji': '😊',
        'message': 'Perfect shape! Keep it up! ⭐',
      };
    } else {
      return {
        'type': 'BULK',
        'emoji': '😅',
        'message': 'Let\'s get active together! 🏃',
      };
    }
  }
}

// Character Painters
class _UnderweightCharacterPainter extends CustomPainter {
  final double idleOffset;
  final bool isBlinking;
  final double energyLevel;

  _UnderweightCharacterPainter({
    required this.idleOffset,
    required this.isBlinking,
    required this.energyLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw thin body
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Thin neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 5),
        width: 15,
        height: 20,
      ),
      bodyPaint,
    );
    
    // Small head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 10 + idleOffset * 2),
      20,
      bodyPaint,
    );
    
    // Draw eyes
    final eyeY = center.dy - 15 + idleOffset * 2;
    
    if (!isBlinking) {
      // Eyes open (looking worried)
      canvas.drawCircle(
        Offset(center.dx - 8, eyeY),
        4,
        Paint()..color = Colors.black,
      );
      canvas.drawCircle(
        Offset(center.dx + 8, eyeY),
        4,
        Paint()..color = Colors.black,
      );
    } else {
      // Eyes closed
      final linePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(center.dx - 10, eyeY),
        Offset(center.dx - 6, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + 6, eyeY),
        Offset(center.dx + 10, eyeY),
        linePaint,
      );
    }
    
    // Worried mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final mouthPath = Path();
    mouthPath.moveTo(center.dx - 8, center.dy - 5);
    mouthPath.quadraticBezierTo(
      center.dx,
      center.dy,
      center.dx + 8,
      center.dy - 5,
    );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NormalCharacterPainter extends CustomPainter {
  final double idleOffset;
  final bool isBlinking;
  final double energyLevel;

  _NormalCharacterPainter({
    required this.idleOffset,
    required this.isBlinking,
    required this.energyLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw fit body
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Muscular neck/body
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 8),
        width: 25,
        height: 25,
      ),
      bodyPaint,
    );
    
    // Strong head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 10 + idleOffset * 2),
      22,
      bodyPaint,
    );
    
    // Draw eyes
    final eyeY = center.dy - 15 + idleOffset * 2;
    
    if (!isBlinking) {
      // Happy eyes
      canvas.drawCircle(
        Offset(center.dx - 9, eyeY),
        5,
        Paint()..color = Colors.black,
      );
      canvas.drawCircle(
        Offset(center.dx + 9, eyeY),
        5,
        Paint()..color = Colors.black,
      );
      
      // Eye sparkle
      final sparklePaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(center.dx - 10, eyeY - 2),
        2,
        sparklePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 8, eyeY - 2),
        2,
        sparklePaint,
      );
    } else {
      // Blinking
      final linePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(center.dx - 11, eyeY),
        Offset(center.dx - 7, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + 7, eyeY),
        Offset(center.dx + 11, eyeY),
        linePaint,
      );
    }
    
    // Big smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final mouthPath = Path();
    mouthPath.moveTo(center.dx - 12, center.dy - 5);
    mouthPath.quadraticBezierTo(
      center.dx,
      center.dy + 5,
      center.dx + 12,
      center.dy - 5,
    );
    canvas.drawPath(mouthPath, mouthPaint);
    
    // Muscle flex animation
    if (energyLevel > 0.5) {
      final musclePaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(center.dx - 15, center.dy + 10),
        5,
        musclePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 15, center.dy + 10),
        5,
        musclePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _OverweightCharacterPainter extends CustomPainter {
  final double idleOffset;
  final bool isBlinking;
  final double energyLevel;

  _OverweightCharacterPainter({
    required this.idleOffset,
    required this.isBlinking,
    required this.energyLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw bigger body
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Rounder body
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 10),
        width: 35,
        height: 30,
      ),
      bodyPaint,
    );
    
    // Larger head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 12 + idleOffset * 2),
      24,
      bodyPaint,
    );
    
    // Draw eyes
    final eyeY = center.dy - 15 + idleOffset * 2;
    
    if (!isBlinking) {
      // Determined eyes
      canvas.drawCircle(
        Offset(center.dx - 10, eyeY),
        5,
        Paint()..color = Colors.black,
      );
      canvas.drawCircle(
        Offset(center.dx + 10, eyeY),
        5,
        Paint()..color = Colors.black,
      );
    } else {
      // Blinking
      final linePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(center.dx - 12, eyeY),
        Offset(center.dx - 8, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + 8, eyeY),
        Offset(center.dx + 12, eyeY),
        linePaint,
      );
    }
    
    // Determined mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final mouthPath = Path();
    mouthPath.moveTo(center.dx - 14, center.dy - 2);
    mouthPath.quadraticBezierTo(
      center.dx,
      center.dy + 3,
      center.dx + 14,
      center.dy - 2,
    );
    canvas.drawPath(mouthPath, mouthPaint);
    
    // Sweat drop animation for overweight (shows effort)
    if (energyLevel > 0.3) {
      final sweatPaint = Paint()
        ..color = Colors.lightBlue.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(center.dx - 5, center.dy - 25),
        3 + energyLevel * 2,
        sweatPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}