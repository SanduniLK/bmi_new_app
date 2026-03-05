import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/food_model.dart';
import '../utils/constants.dart';

class UserDashboard extends StatefulWidget {
  final AppUser user;
  
  const UserDashboard({super.key, required this.user});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late double bmi;
  late String bmiCategory;
  late List<FoodItem> recommendations;
  late Map<String, dynamic> mealPlan;

  @override
  void initState() {
    super.initState();
    bmi = widget.user.calculateBMI() ?? 0;
    bmiCategory = widget.user.getBMICategory() ?? 'Normal';
    
    // Use dietTypes instead of foodPreferences
    List<String> preferences = widget.user.dietTypes;  // Changed from foodPreferences
    
    // Use healthGoal instead of dietGoal
    String goal = widget.user.healthGoal ?? 'maintenance';  // Changed from dietGoal
    
    // Get personalized recommendations (simplified for now)
    recommendations = _getSampleFoods();
    
    mealPlan = _getSampleMealPlan();
  }

  List<FoodItem> _getSampleFoods() {
    return [
      FoodItem(
        id: '1',
        name: 'Grilled Chicken Salad',
        description: 'Healthy grilled chicken with fresh vegetables',
        category: 'Main Course',
        calories: 350,
        protein: 35,
        carbs: 10,
        fats: 15,
        fiber: 8,
        suitableForBMI: ['normal', 'overweight'],
        dietaryTags: ['High Protein', 'Low Carb'],
        mealType: ['Lunch', 'Dinner'],
        healthBenefits: ['Muscle building', 'Weight loss'],
        imageUrl: null,
        isIndianFood: false,
        preparationTime: 20,
        ingredients: ['Chicken', 'Lettuce', 'Tomatoes'],
      ),
      // Add more sample foods as needed
    ];
  }

  Map<String, dynamic> _getSampleMealPlan() {
    return {
      'breakfast': _getSampleFoods().take(1).toList(),
      'lunch': _getSampleFoods().take(2).toList(),
      'snacks': _getSampleFoods().take(1).toList(),
      'dinner': _getSampleFoods().take(1).toList(),
    };
  }

  Color _getBMIColor() {
    if (bmi < 18.5) return AppColors.underweight;
    if (bmi < 25) return AppColors.normal;
    if (bmi < 30) return AppColors.overweight;
    return AppColors.obese;
  }

  String _getPersonalizedMessage() {
    if (bmi < 18.5) {
      return "Based on your BMI, we recommend nutrient-dense foods to help you gain healthy weight. Check out our high-protein recommendations!";
    } else if (bmi < 25) {
      return "Great job maintaining a healthy BMI! Here are some delicious meals to keep you on track.";
    } else if (bmi < 30) {
      return "We've selected low-calorie, high-fiber options to support your weight management goals.";
    } else {
      return "Let's focus on healthy, nutritious foods. We've picked some great options to start your wellness journey.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${widget.user.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_getBMIColor(), _getBMIColor().withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your BMI',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              widget.user.gender == 'Male' ? Icons.male : Icons.female,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bmiCategory,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Personalized Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getPersonalizedMessage(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Diet Preferences
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Diet Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: widget.user.dietTypes.map((diet) {
                      return Chip(
                        label: Text(diet),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: AppColors.primary),
                      );
                    }).toList(),
                  ),
                  if (widget.user.healthGoal != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Goal: ${widget.user.healthGoal}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Today's Meal Plan
            const Text(
              '🍽️ Today\'s Recommended Meal Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildMealSection('Breakfast', mealPlan['breakfast'] ?? []),
            _buildMealSection('Lunch', mealPlan['lunch'] ?? []),
            _buildMealSection('Snacks', mealPlan['snacks'] ?? []),
            _buildMealSection('Dinner', mealPlan['dinner'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<FoodItem> items) {
    if (items.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              item.calories.toString(),
              style: const TextStyle(fontSize: 10, color: AppColors.primary),
            ),
          ),
          title: Text(item.name),
          subtitle: Text('${item.protein}g protein • ${item.carbs}g carbs'),
          trailing: Icon(Icons.info_outline, color: AppColors.primary),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}