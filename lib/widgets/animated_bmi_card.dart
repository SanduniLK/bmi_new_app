import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/bmi_record.dart';
import '../utils/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBMICard extends StatefulWidget {
  const AnimatedBMICard({super.key});

  @override
  State<AnimatedBMICard> createState() => _AnimatedBMICardState();
}

class _AnimatedBMICardState extends State<AnimatedBMICard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  BMIRecord? _latestBMI;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _loadLatestBMI();
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerCard();
    }

    if (_latestBMI == null) {
      return _buildEmptyState();
    }

    return _buildBMICard(_latestBMI!);
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardShadow,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No BMI Record Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to calculate your BMI',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().shake(),
    );
  }

  Widget _buildBMICard(BMIRecord record) {
    final bmiColor = _getBMIColor(record.bmi);
    final bmiCategory = record.category;
    
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bmiColor.withValues(alpha: 0.8), bmiColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bmiColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: _BMIBackgroundPainter(),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left side - BMI value
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Your BMI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              record.bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn().scale(),
                            const SizedBox(width: 4),
                            const Text(
                              'kg/m²',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bmiCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right side - BMI gauge
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBMIGauge(record.bmi),
                        const SizedBox(height: 8),
                        Text(
                          'Updated ${_getTimeAgo(record.date)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIGauge(double bmi) {
    double percentage = _getBMIPercentage(bmi);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: percentage,
            strokeWidth: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBMIArrow(bmi),
              color: Colors.white,
              size: 20,
            ),
            Text(
              _getBMITrend(bmi),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return AppColors.underweight;
    if (bmi < 25) return AppColors.normal;
    if (bmi < 30) return AppColors.overweight;
    return AppColors.obese;
  }

  double _getBMIPercentage(double bmi) {
    if (bmi < 18.5) return bmi / 40;
    if (bmi < 25) return bmi / 40;
    if (bmi < 30) return bmi / 40;
    return bmi / 40;
  }

  IconData _getBMIArrow(double bmi) {
    if (bmi < 18.5) return Icons.arrow_downward;
    if (bmi < 25) return Icons.remove;
    if (bmi < 30) return Icons.arrow_upward;
    return Icons.warning;
  }

  String _getBMITrend(double bmi) {
    if (bmi < 18.5) return 'Low';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'High';
    return 'Critical';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _BMIBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startX = -20.0 + (i * 40);
      final startY = size.height + 20.0;
      
      path.moveTo(startX, startY);
      path.lineTo(startX + 60, startY - 60);
      path.lineTo(startX + 120, startY);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}