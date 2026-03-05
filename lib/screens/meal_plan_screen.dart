import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../utils/constants.dart';
import 'food_detail_screen.dart';

class MealPlanScreen extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanScreen({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meal Plan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealPlan.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mealPlan.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildNutrientChip(
                        '${mealPlan.totalCalories.toStringAsFixed(0)} kcal',
                        Icons.local_fire_department,
                      ),
                      const SizedBox(width: 8),
                      _buildNutrientChip(
                        '${mealPlan.totalProtein.toStringAsFixed(0)}g Protein',
                        Icons.fitness_center,
                      ),
                      const SizedBox(width: 8),
                      _buildNutrientChip(
                        mealPlan.duration,
                        Icons.timer,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Breakfast
            _buildMealSection('Breakfast', mealPlan.breakfast, context),
            
            // Lunch
            _buildMealSection('Lunch', mealPlan.lunch, context),
            
            // Snacks
            _buildMealSection('Snacks', mealPlan.snacks, context),
            
            // Dinner
            _buildMealSection('Dinner', mealPlan.dinner, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, List<FoodItem> foods, BuildContext context) {
    if (foods.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...foods.map((food) => _buildFoodTile(food, context)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFoodTile(FoodItem food, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${food.calories.toInt()}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${food.protein}g protein • ${food.carbs}g carbs',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          color: AppColors.primary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(food: food),
              ),
            );
          },
        ),
      ),
    );
  }
}