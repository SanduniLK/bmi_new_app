import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============= GET PERSONALIZED RECOMMENDATIONS =============

  /// Get personalized food recommendations based on user profile
  Stream<List<FoodItem>> getPersonalizedRecommendations(AppUser user) {
    final bmiCategory = user.getBMICategory()?.toLowerCase() ?? 'normal';
    final preferences = user.foodPreferences ?? [];
    final dietGoal = user.dietGoal?.toLowerCase() ?? 'maintenance';

    final query = _firestore
        .collection('foods')
        .where('suitableForBMI', arrayContains: bmiCategory);

    return query.snapshots().map((snapshot) {
      final List<FoodItem> foods = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        foods.add(FoodItem.fromJson(data, doc.id));
      }
      
      // Score and sort based on user preferences
      foods.sort((a, b) {
        final scoreA = _calculateFoodScore(a, preferences, dietGoal);
        final scoreB = _calculateFoodScore(b, preferences, dietGoal);
        return scoreB.compareTo(scoreA);
      });

      return foods;
    });
  }

  // ============= GET POPULAR FOODS =============

  /// Get popular foods (highest rated)
  Stream<List<FoodItem>> getPopularFoods({int limit = 10}) {
    return _firestore
        .collection('foods')
        .where('isPopular', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final List<FoodItem> foods = [];
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            foods.add(FoodItem.fromJson(data, doc.id));
          }
          
          return foods;
        });
  }

  // ============= GET ALL FOODS =============

  /// Get all foods (for admin panel)
  Stream<List<FoodItem>> getAllFoods() {
    return _firestore
        .collection('foods')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          final List<FoodItem> foods = [];
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            foods.add(FoodItem.fromJson(data, doc.id));
          }
          
          return foods;
        });
  }

  // ============= GET SINGLE FOOD BY ID =============

  /// Get a single food item by its ID
  Future<FoodItem?> getFoodById(String foodId) async {
    try {
      final doc = await _firestore.collection('foods').doc(foodId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return FoodItem.fromJson(data, doc.id);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting food: $e');
      return null;
    }
  }

  // ============= GET PERSONALIZED MEAL PLAN =============

  /// Get a personalized meal plan based on user profile
  Future<MealPlan?> getPersonalizedMealPlan(AppUser user) async {
    try {
      final bmiCategory = user.getBMICategory()?.toLowerCase() ?? 'normal';
      final preferences = user.foodPreferences ?? [];
      final dietGoal = user.dietGoal?.toLowerCase() ?? 'maintenance';

      // Get breakfast options
      final breakfastSnapshot = await _firestore
          .collection('foods')
          .where('suitableForBMI', arrayContains: bmiCategory)
          .where('mealType', arrayContains: 'Breakfast')
          .limit(10)
          .get();

      // Get lunch options
      final lunchSnapshot = await _firestore
          .collection('foods')
          .where('suitableForBMI', arrayContains: bmiCategory)
          .where('mealType', arrayContains: 'Lunch')
          .limit(10)
          .get();

      // Get dinner options
      final dinnerSnapshot = await _firestore
          .collection('foods')
          .where('suitableForBMI', arrayContains: bmiCategory)
          .where('mealType', arrayContains: 'Dinner')
          .limit(10)
          .get();

      // Get snack options
      final snackSnapshot = await _firestore
          .collection('foods')
          .where('suitableForBMI', arrayContains: bmiCategory)
          .where('mealType', arrayContains: 'Snacks')
          .limit(10)
          .get();

      final breakfast = _documentsToFoodList(breakfastSnapshot);
      final lunch = _documentsToFoodList(lunchSnapshot);
      final dinner = _documentsToFoodList(dinnerSnapshot);
      final snacks = _documentsToFoodList(snackSnapshot);

      // Score and sort based on preferences and goals
      final sortedBreakfast = _scoreAndSortFoods(breakfast, preferences, dietGoal);
      final sortedLunch = _scoreAndSortFoods(lunch, preferences, dietGoal);
      final sortedDinner = _scoreAndSortFoods(dinner, preferences, dietGoal);
      final sortedSnacks = _scoreAndSortFoods(snacks, preferences, dietGoal);

      return MealPlan.fromFoods(
        id: 'personalized_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Your Personalized Meal Plan',
        description: 'Based on your BMI: ${user.getBMICategory() ?? 'Normal'}',
        breakfast: sortedBreakfast.take(2).toList(),
        lunch: sortedLunch.take(3).toList(),
        dinner: sortedDinner.take(3).toList(),
        snacks: sortedSnacks.take(2).toList(),
        suitableForBMI: bmiCategory,
        dietaryTags: preferences,
        duration: '1 day',
      );
    } catch (e) {
      debugPrint('Error creating meal plan: $e');
      return null;
    }
  }

  // ============= ADMIN: ADD FOOD =============

  /// Add a new food to the database (admin only)
  Future<void> addFood(FoodItem food) async {
    try {
      await _firestore.collection('foods').doc(food.id).set(food.toJson());
      debugPrint('✅ Food added successfully: ${food.name}');
    } catch (e) {
      debugPrint('❌ Error adding food: $e');
      rethrow;
    }
  }

  // ============= ADMIN: UPDATE FOOD =============

  /// Update an existing food (admin only)
  Future<void> updateFood(FoodItem food) async {
    try {
      await _firestore.collection('foods').doc(food.id).update(food.toJson());
      debugPrint('✅ Food updated successfully: ${food.name}');
    } catch (e) {
      debugPrint('❌ Error updating food: $e');
      rethrow;
    }
  }

  // ============= ADMIN: DELETE FOOD =============

  /// Delete a food (admin only)
  Future<void> deleteFood(String foodId) async {
    try {
      await _firestore.collection('foods').doc(foodId).delete();
      debugPrint('✅ Food deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting food: $e');
      rethrow;
    }
  }

  // ============= HELPER METHODS =============

  /// Convert QuerySnapshot to List<FoodItem>
  List<FoodItem> _documentsToFoodList(QuerySnapshot snapshot) {
    final List<FoodItem> foods = [];
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        foods.add(FoodItem.fromJson(data, doc.id));
      }
    }
    
    return foods;
  }

  /// Score and sort a list of foods
  List<FoodItem> _scoreAndSortFoods(
    List<FoodItem> foods, 
    List<String> preferences, 
    String dietGoal,
  ) {
    final scoredFoods = List<FoodItem>.from(foods);
    scoredFoods.sort((a, b) {
      final scoreA = _calculateFoodScore(a, preferences, dietGoal);
      final scoreB = _calculateFoodScore(b, preferences, dietGoal);
      return scoreB.compareTo(scoreA);
    });
    return scoredFoods;
  }

  /// Calculate score for a food item based on user preferences
  int _calculateFoodScore(FoodItem food, List<String> preferences, String dietGoal) {
    var score = 0;

    // Preference match (highest weight)
    if (preferences.isNotEmpty) {
      for (final tag in food.dietaryTags) {
        if (preferences.any((p) => tag.toLowerCase().contains(p.toLowerCase()))) {
          score += 20;
        }
      }
    }

    // Diet goal alignment
    switch (dietGoal) {
      case 'weight loss':
        if (food.calories < 300) score += 15;
        if (food.fiber > 5) score += 10;
        break;
      case 'weight gain':
        if (food.calories > 400) score += 15;
        if (food.protein > 20) score += 10;
        break;
      case 'muscle building':
        if (food.protein > 20) score += 25;
        break;
    }

    // Rating boost
    if (food.rating > 4.5) {
      score += 10;
    } else if (food.rating > 4.0) {
      score += 5;
    }

    // Popularity boost
    if (food.isPopular) {
      score += 5;
    }

    return score;
  }
}