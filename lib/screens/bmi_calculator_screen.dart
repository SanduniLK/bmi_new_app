import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';
import '../models/bmi_record.dart';
import '../utils/constants.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Scroll picker values
  int _selectedWeight = 70;
  int _selectedHeight = 170;
  int _selectedAge = 30;
  
  // Controllers for scroll pickers
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _heightController;
  late FixedExtentScrollController _ageController;
  
  bool _isLoading = false;
  double? _bmiResult;
  String? _bmiCategory;
  String? _advice;
  
  late AnimationController _characterController;
  late AnimationController _scaleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _showCharacter = false;
  final double _characterSize = 120;

  @override
  void initState() {
    super.initState();
    
    _weightController = FixedExtentScrollController(initialItem: _selectedWeight - 30);
    _heightController = FixedExtentScrollController(initialItem: _selectedHeight - 100);
    _ageController = FixedExtentScrollController(initialItem: _selectedAge - 18);
    
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _characterController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BMI Calculator')
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Animated Character
              if (_showCharacter) ...[
                Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_characterController, _scaleController]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_bounceAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: _characterSize,
                            height: _characterSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getCategoryColor().withValues(alpha: 0.3),
                                  _getCategoryColor().withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Character silhouette
                                CustomPaint(
                                  size: Size(_characterSize, _characterSize),
                                  painter: _CharacterPainter(
                                    color: _getCategoryColor(),
                                    bmi: _bmiResult ?? 22,
                                    isHappy: _bmiResult != null && _bmiResult! >= 18.5 && _bmiResult! < 25,
                                  ),
                                ),
                                
                                // BMI display on character
                                Positioned(
                                  bottom: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getCategoryColor().withValues(alpha: 0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _bmiResult?.toStringAsFixed(1) ?? '?',
                                      style: TextStyle(
                                        color: _getCategoryColor(),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 300.ms),
                ),
                const SizedBox(height: 20),
              ],

              // Input Card with Scroll Pickers
              _buildInputCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // Result Card
              if (_bmiResult != null) ...[
                _buildResultCard().animate().fadeIn(delay: 200.ms).scale(),
              ],

              const SizedBox(height: 20),

              // BMI Scale Indicator
              if (_bmiResult != null) ...[
                _buildBMIScale().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              ],

              const SizedBox(height: 20),

              // Health Tips Card
              if (_bmiResult != null) ...[
                _buildHealthTips().animate().fadeIn(delay: 400.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.background],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text(
              'Enter Your Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Age Picker
            _buildScrollPicker(
              label: 'Age',
              icon: Icons.cake,
              color: Colors.purple,
              unit: 'years',
              min: 18,
              max: 100,
              selectedValue: _selectedAge,
              controller: _ageController,
              onChanged: (value) => setState(() => _selectedAge = value),
            ),
            const SizedBox(height: 20),

            // Weight Picker
            _buildScrollPicker(
              label: 'Weight',
              icon: Icons.monitor_weight,
              color: Colors.blue,
              unit: 'kg',
              min: 30,
              max: 200,
              selectedValue: _selectedWeight,
              controller: _weightController,
              onChanged: (value) => setState(() => _selectedWeight = value),
            ),
            const SizedBox(height: 20),

            // Height Picker
            _buildScrollPicker(
              label: 'Height',
              icon: Icons.height,
              color: Colors.green,
              unit: 'cm',
              min: 100,
              max: 250,
              selectedValue: _selectedHeight,
              controller: _heightController,
              onChanged: (value) => setState(() => _selectedHeight = value),
            ),
            
            const SizedBox(height: 30),

            // Calculate Button
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Calculate BMI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollPicker({
    required String label,
    required IconData icon,
    required Color color,
    required String unit,
    required int min,
    required int max,
    required int selectedValue,
    required FixedExtentScrollController controller,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$selectedValue $unit',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Minus button
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (selectedValue > min) {
                      controller.jumpToItem(selectedValue - min - 1);
                      onChanged(selectedValue - 1);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: color,
                      size: 30,
                    ),
                  ),
                ),
              ),
              
              // Scroll wheel
              Expanded(
                flex: 3,
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 40,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    onChanged(min + index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: max - min + 1,
                    builder: (context, index) {
                      final value = min + index;
                      final isSelected = value == selectedValue;
                      return Center(
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Plus button
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (selectedValue < max) {
                      controller.jumpToItem(selectedValue - min + 1);
                      onChanged(selectedValue + 1);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: color,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getCategoryColor(),
              _getCategoryColor().withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text(
              'Your BMI Result',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _bmiResult!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().scale(duration: 500.ms).then().shake(),
                const SizedBox(width: 8),
                const Text(
                  'kg/m²',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _bmiCategory!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIScale() {
    final categories = [
      {'label': 'Underweight', 'range': '< 18.5', 'color': AppColors.underweight},
      {'label': 'Normal', 'range': '18.5 - 24.9', 'color': AppColors.normal},
      {'label': 'Overweight', 'range': '25 - 29.9', 'color': AppColors.overweight},
      {'label': 'Obese', 'range': '≥ 30', 'color': AppColors.obese},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Scale',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.underweight,
                    AppColors.normal,
                    AppColors.overweight,
                    AppColors.obese,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories.map((cat) {
                final isCurrent = _getCurrentCategory() == cat['label'];
                return Expanded(
                  child: GestureDetector(
                    onTap: null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent 
                            ? (cat['color'] as Color).withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            cat['range'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isCurrent ? cat['color'] as Color : Colors.grey,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrent ? cat['color'] as Color : Colors.grey,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: _getCategoryColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Tip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _advice!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
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

  Future<void> _calculateBMI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      double weight = _selectedWeight.toDouble();
      int height = _selectedHeight;
      
      double heightInM = height / 100;
      double bmi = weight / (heightInM * heightInM);
      
      String category;
      String advice;
      
      if (bmi < 18.5) {
        category = "Underweight";
        advice = "Focus on nutrient-dense foods. Include healthy fats, proteins, and complex carbs. Consider consulting a nutritionist.";
      } else if (bmi < 25) {
        category = "Normal";
        advice = "Great job! Maintain your healthy weight with balanced diet and regular exercise. Stay consistent!";
      } else if (bmi < 30) {
        category = "Overweight";
        advice = "Incorporate more physical activity. Focus on portion control and whole foods. Every step counts!";
      } else {
        category = "Obese";
        advice = "Consult with healthcare providers. Start with small, sustainable changes. Your health journey begins today!";
      }

      // Save to Firebase if user is logged in
      if (FirebaseAuth.instance.currentUser != null) {
        final record = BMIRecord(
          bmi: bmi,
          weight: weight,
          height: height,
          category: category,
          date: DateTime.now(),
        );
        await _firebaseService.saveBMIRecord(record);
      }

      if (!mounted) return;

      setState(() {
        _bmiResult = bmi;
        _bmiCategory = category;
        _advice = advice;
        _isLoading = false;
        _showCharacter = true;
      });

      _scaleController.forward(from: 0);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCategoryColor() {
    if (_bmiResult == null) return AppColors.primary;
    if (_bmiResult! < 18.5) return AppColors.underweight;
    if (_bmiResult! < 25) return AppColors.normal;
    if (_bmiResult! < 30) return AppColors.overweight;
    return AppColors.obese;
  }

  String _getCurrentCategory() {
    if (_bmiResult == null) return '';
    if (_bmiResult! < 18.5) return 'Underweight';
    if (_bmiResult! < 25) return 'Normal';
    if (_bmiResult! < 30) return 'Overweight';
    return 'Obese';
  }
}

class _CharacterPainter extends CustomPainter {
  final Color color;
  final double bmi;
  final bool isHappy;

  _CharacterPainter({
    required this.color,
    required this.bmi,
    required this.isHappy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw head
    canvas.drawCircle(center, radius, paint);
    
    // Draw eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    
    // Eye positions based on BMI (wider eyes for higher BMI)
    final eyeSpacing = radius * (0.3 + (bmi / 100));
    final eyeY = center.dy - radius * 0.2;
    
    // Left eye
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing, eyeY),
      radius * 0.15,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing, eyeY),
      radius * 0.07,
      pupilPaint,
    );
    
    // Right eye
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing, eyeY),
      radius * 0.15,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing, eyeY),
      radius * 0.07,
      pupilPaint,
    );
    
    // Draw mouth based on mood
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1;
    
    final mouthPath = Path();
    final mouthY = center.dy + radius * 0.2;
    
    if (isHappy) {
      // Happy smile
      mouthPath.moveTo(center.dx - radius * 0.4, mouthY);
      mouthPath.quadraticBezierTo(
        center.dx,
        mouthY + radius * 0.3,
        center.dx + radius * 0.4,
        mouthY,
      );
    } else {
      // Sad or neutral mouth based on BMI
      if (bmi < 18.5 || bmi > 30) {
        // Sad frown
        mouthPath.moveTo(center.dx - radius * 0.4, mouthY + radius * 0.2);
        mouthPath.quadraticBezierTo(
          center.dx,
          mouthY,
          center.dx + radius * 0.4,
          mouthY + radius * 0.2,
        );
      } else {
        // Neutral line
        mouthPath.moveTo(center.dx - radius * 0.4, mouthY + radius * 0.1);
        mouthPath.lineTo(center.dx + radius * 0.4, mouthY + radius * 0.1);
      }
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}