import 'package:bmi_new_app/screens/add_food_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/bmr_model.dart';
import '../../models/user_model.dart';
import '../../services/bmr_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_flame.dart';
import '../../widgets/macro_chart.dart';
import 'add_food_screen.dart';

class BMRCalculatorScreen extends StatefulWidget {
  const BMRCalculatorScreen({super.key});

  @override
  State<BMRCalculatorScreen> createState() => _BMRCalculatorScreenState();
}

class _BMRCalculatorScreenState extends State<BMRCalculatorScreen> with TickerProviderStateMixin {
  // User data
  AppUser? _currentUser;
  
  // Input controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  // Selected values
  String _selectedGender = 'Female';
  ActivityLevel _selectedActivity = ActivityLevel.sedentary;
  
  // Results
  double? _bmr;
  double? _tdee;
  Map<String, dynamic>? _nutritionPlan;
  
  // Meal tracking
  List<FoodEntry> _todayFoods = [];
  Map<String, double> _dailyTotals = {};
  
  // Animation controllers
  late AnimationController _flameController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  bool _isLoading = true;
  bool _showResults = false;
  bool _showMealTracker = false;

  @override
  void initState() {
    super.initState();
    
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    _loadUserData();
    _loadTodayFoods();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestoreService = FirestoreService();
      final userData = await firestoreService.getAppUser(user.uid);
      
      if (mounted && userData != null) {
        setState(() {
          _currentUser = userData;
          
          // Pre-fill with user data
          if (userData.age != null) {
            _ageController.text = userData.age!.toString();
          }
          if (userData.weight != null) {
            _weightController.text = userData.weight!.toString();
          }
          if (userData.height != null) {
            _heightController.text = userData.height!.toString();
          }
          if (userData.gender != null) {
            _selectedGender = userData.gender!;
          }
          if (userData.activityLevel != null) {
            _selectedActivity = ActivityLevel.fromString(userData.activityLevel);
          }
          
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTodayFoods() async {
    final bmrService = BMRService();
    bmrService.getTodayFoodEntries().listen((foods) {
      if (mounted) {
        setState(() {
          _todayFoods = foods;
          _calculateTotals();
        });
      }
    });
  }

  void _calculateTotals() {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;

    for (var food in _todayFoods) {
      calories += food.calories;
      protein += food.protein;
      carbs += food.carbs;
      fats += food.fats;
    }

    _dailyTotals = {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  void _calculateBMR() {
    if (_ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      int age = int.parse(_ageController.text);
      double weight = double.parse(_weightController.text);
      int height = int.parse(_heightController.text);

      // Calculate BMR using Mifflin-St Jeor Equation
      if (_selectedGender.toLowerCase() == 'male') {
        // Men: BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
        _bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else {
        // Women: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161
        _bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }

      // Calculate TDEE (Total Daily Energy Expenditure)
      _tdee = _bmr! * _selectedActivity.factor;

      // Get nutrition plan based on user's goal
      _nutritionPlan = BMCCalculator.getNutritionPlan(
        _tdee!,
        _currentUser?.dietGoal ?? 'Maintenance',
      );

      setState(() {
        _showResults = true;
        _showMealTracker = true;
      });

      _progressController.forward(from: 0);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get _remainingCalories {
    if (_nutritionPlan == null) return 0;
    return (_nutritionPlan!['calorieTarget'] - (_dailyTotals['calories'] ?? 0))
        .clamp(0, double.infinity);
  }

  double get _calorieProgress {
    if (_nutritionPlan == null) return 0;
    return (_dailyTotals['calories'] ?? 0) / _nutritionPlan!['calorieTarget'];
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _flameController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BMR Calculator')
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
              // Flame Header
              _buildFlameHeader().animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),
              
              // Input Form
              _buildInputForm().animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 24),
              
              // Calculate Button
              _buildCalculateButton().animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 24),
              
              // Results Section
              if (_showResults && _bmr != null) ...[
                _buildResultsCard().animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 20),
                
                // Daily Recommendation
                _buildRecommendationCard().animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 20),
                
                // Calorie Ring
                _buildCalorieRing().animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 20),
                
                // Meal Tracker
                if (_showMealTracker) ...[
                  _buildMealTracker().animate().fadeIn(delay: 700.ms),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Add Food Button
                  _buildQuickAddButton().animate().fadeIn(delay: 800.ms),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildFlameHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700,
            Colors.orange.shade500,
            Colors.amber.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _flameController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + _flameController.value * 0.1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMR Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enter your details to calculate daily calories',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Your Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Age Input
          _buildInputField(
            controller: _ageController,
            label: 'Age',
            icon: Icons.cake,
            unit: 'years',
          ),
          const SizedBox(height: 16),

          // Gender Selection
          _buildGenderSelector(),
          const SizedBox(height: 16),

          // Weight Input
          _buildInputField(
            controller: _weightController,
            label: 'Weight',
            icon: Icons.monitor_weight,
            unit: 'kg',
          ),
          const SizedBox(height: 16),

          // Height Input
          _buildInputField(
            controller: _heightController,
            label: 'Height',
            icon: Icons.height,
            unit: 'cm',
          ),
          const SizedBox(height: 16),

          // Activity Level
          _buildActivitySelector(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter $label',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderChip('Male', Icons.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderChip('Female', Icons.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    gender == 'Male' ? Colors.blue : Colors.pink,
                    gender == 'Male' ? Colors.lightBlue : Colors.pinkAccent,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: ActivityLevel.values.map((level) {
              final isSelected = _selectedActivity == level;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedActivity = level;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.label,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? AppColors.primary : Colors.black,
                              ),
                            ),
                            Text(
                              level.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${level.factor}x',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _calculateBMR,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24 + _pulseController.value * 4,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'CALCULATE BMR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final bmrCategory = BMCCalculator.getBMRCategory(_bmr!, _selectedGender);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your BMR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bmrCategory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _bmr!.round().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'kcal/day',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResultItem(
                'TDEE',
                '${_tdee!.round()} kcal',
                Icons.flash_on,
              ),
              _buildResultItem(
                'Activity',
                '${_selectedActivity.factor}x',
                Icons.directions_run,
              ),
              _buildResultItem(
                'Goal',
                _currentUser?.dietGoal ?? 'Maintenance',
                Icons.flag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Daily Recommendation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Target Calories',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_nutritionPlan!['calorieTarget']} kcal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Macronutrient Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  'Protein',
                  '${_nutritionPlan!['protein']}g',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMacroItem(
                  'Carbs',
                  '${_nutritionPlan!['carbs']}g',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildMacroItem(
                  'Fats',
                  '${_nutritionPlan!['fats']}g',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _nutritionPlan!['recommendation'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildCalorieRing() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: _calorieProgress * _progressAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _calorieProgress > 1.0 ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_dailyTotals['calories']?.round() ?? 0}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _calorieProgress > 1.0 ? AppColors.error : AppColors.primary,
                        ),
                      ),
                      Text(
                        'of ${_nutritionPlan!['calorieTarget']} kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _calorieProgress > 1.0
                    ? 'You\'ve exceeded your goal!'
                    : '${_remainingCalories.round()} kcal remaining',
                style: TextStyle(
                  color: _calorieProgress > 1.0 ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealTracker() {
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    final mealNames = {'breakfast': 'Breakfast', 'lunch': 'Lunch', 'dinner': 'Dinner', 'snack': 'Snacks'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Meals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...mealTypes.map((type) => _buildMealSection(
          mealNames[type]!,
          _todayFoods.where((f) => f.mealType == type).toList(),
          type,
        )),
      ],
    );
  }

  Widget _buildMealSection(String title, List<FoodEntry> entries, String mealType) {
    final mealCalories = entries.fold(0.0, (sum, e) => sum + e.calories);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${mealCalories.round()} kcal',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => _navigateToAddFood(mealType: mealType),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'No foods added',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...entries.map((food) => Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      food.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${food.calories.round()} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToAddFood(),
        icon: const Icon(Icons.add),
        label: const Text('Quick Add Food'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _navigateToAddFood({String mealType = 'snack'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(
          mealType: mealType,
          onFoodAdded: () {
            // Refresh will happen automatically via Stream
          },
        ),
      ),
    );
  }
}