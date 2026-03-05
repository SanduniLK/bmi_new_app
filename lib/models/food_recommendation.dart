import 'package:flutter/material.dart';

// ============= ENUMS =============

enum FoodCategory {
  vegetarian,
  vegan,
  nonVegetarian,
  eggetarian,
  glutenFree,
  dairyFree,
  keto,
  lowCarb,
  highProtein,
  lowFat,
}

enum DietGoal {
  weightLoss,
  weightGain,
  muscleBuilding,
  maintenance,
  healthImprovement
}

// ============= FOOD ITEM CLASS =============

class FoodItem {
  final String name;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final List<String> suitableForBMI; // 'underweight', 'normal', 'overweight', 'obese'
  final List<FoodCategory> suitableForDiet;
  final List<String> healthBenefits;
  final String imageAsset;
  final bool isIndianFood;
  
  FoodItem({
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.suitableForBMI,
    required this.suitableForDiet,
    required this.healthBenefits,
    required this.imageAsset,
    required this.isIndianFood,
  });
}

// ============= FOOD RECOMMENDATION ENGINE =============

class FoodRecommendationEngine {
  // Indian food database
  static final List<FoodItem> indianFoods = [
    // High protein - Good for underweight
    FoodItem(
      name: "Paneer Butter Masala",
      category: "Main Course",
      calories: 450,
      protein: 18,
      carbs: 12,
      fats: 35,
      suitableForBMI: ["underweight", "normal"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.highProtein],
      healthBenefits: ["High protein", "Good for muscle gain", "Calcium rich"],
      imageAsset: "assets/foods/paneer.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Chicken Biryani",
      category: "Main Course",
      calories: 550,
      protein: 25,
      carbs: 60,
      fats: 20,
      suitableForBMI: ["underweight", "normal"],
      suitableForDiet: [FoodCategory.nonVegetarian, FoodCategory.highProtein],
      healthBenefits: ["Complete protein", "Energy rich", "Digestive spices"],
      imageAsset: "assets/foods/biryani.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Dal Makhani",
      category: "Main Course",
      calories: 300,
      protein: 15,
      carbs: 30,
      fats: 12,
      suitableForBMI: ["underweight", "normal", "overweight"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.vegan],
      healthBenefits: ["High fiber", "Plant protein", "Iron rich"],
      imageAsset: "assets/foods/dal.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Masala Dosa",
      category: "Breakfast",
      calories: 250,
      protein: 6,
      carbs: 40,
      fats: 8,
      suitableForBMI: ["normal", "overweight"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.lowFat],
      healthBenefits: ["Fermented food", "Easy to digest", "Probiotic"],
      imageAsset: "assets/foods/dosa.jpg",
      isIndianFood: true,
    ),
    
    // Low calorie - Good for overweight/obese
    FoodItem(
      name: "Grilled Fish (Tandoori)",
      category: "Appetizer",
      calories: 180,
      protein: 28,
      carbs: 2,
      fats: 6,
      suitableForBMI: ["overweight", "obese"],
      suitableForDiet: [FoodCategory.nonVegetarian, FoodCategory.lowCarb, FoodCategory.keto],
      healthBenefits: ["Lean protein", "Omega-3", "Low calorie"],
      imageAsset: "assets/foods/tandoori.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Vegetable Salad",
      category: "Salad",
      calories: 80,
      protein: 3,
      carbs: 15,
      fats: 2,
      suitableForBMI: ["overweight", "obese", "normal"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.vegan, FoodCategory.lowCarb],
      healthBenefits: ["High fiber", "Vitamins", "Hydrating"],
      imageAsset: "assets/foods/salad.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Oats Upma",
      category: "Breakfast",
      calories: 200,
      protein: 8,
      carbs: 35,
      fats: 5,
      suitableForBMI: ["overweight", "obese", "normal"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.lowFat],
      healthBenefits: ["Low glycemic", "High fiber", "Heart healthy"],
      imageAsset: "assets/foods/upma.jpg",
      isIndianFood: true,
    ),
    
    // Protein rich for muscle building
    FoodItem(
      name: "Soya Chaap",
      category: "Main Course",
      calories: 320,
      protein: 25,
      carbs: 15,
      fats: 18,
      suitableForBMI: ["underweight", "normal"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.highProtein],
      healthBenefits: ["Plant protein", "Isoflavones", "Low cholesterol"],
      imageAsset: "assets/foods/soyachaap.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Egg Curry",
      category: "Main Course",
      calories: 280,
      protein: 18,
      carbs: 8,
      fats: 20,
      suitableForBMI: ["underweight", "normal"],
      suitableForDiet: [FoodCategory.eggetarian, FoodCategory.highProtein],
      healthBenefits: ["Complete protein", "Vitamin B12", "Good fats"],
      imageAsset: "assets/foods/eggcurry.jpg",
      isIndianFood: true,
    ),
    
    // Healthy snacks
    FoodItem(
      name: "Roasted Chana",
      category: "Snacks",
      calories: 120,
      protein: 7,
      carbs: 20,
      fats: 2,
      suitableForBMI: ["underweight", "normal", "overweight", "obese"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.vegan, FoodCategory.glutenFree],
      healthBenefits: ["High protein snack", "Good for diabetes", "Iron rich"],
      imageAsset: "assets/foods/chana.jpg",
      isIndianFood: true,
    ),
    FoodItem(
      name: "Sprouts Salad",
      category: "Snacks",
      calories: 100,
      protein: 8,
      carbs: 18,
      fats: 1,
      suitableForBMI: ["underweight", "normal", "overweight", "obese"],
      suitableForDiet: [FoodCategory.vegetarian, FoodCategory.vegan],
      healthBenefits: ["Enzymes rich", "Vitamin C", "Digestive"],
      imageAsset: "assets/foods/sprouts.jpg",
      isIndianFood: true,
    ),
  ];

  // ============= RECOMMENDATION METHODS =============

  static List<FoodItem> getRecommendations({
    required String bmiCategory,
    required List<FoodCategory> preferences,
    required DietGoal goal,
    int limit = 5
  }) {
    // First, filter by BMI suitability
    List<FoodItem> filtered = indianFoods.where((food) {
      return food.suitableForBMI.contains(bmiCategory.toLowerCase());
    }).toList();
    
    // Then filter by dietary preferences
    filtered = filtered.where((food) {
      return food.suitableForDiet.any((diet) => preferences.contains(diet));
    }).toList();
    
    // Sort based on goal
    switch (goal) {
      case DietGoal.weightLoss:
        filtered.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      case DietGoal.weightGain:
      case DietGoal.muscleBuilding:
        filtered.sort((a, b) => b.protein.compareTo(a.protein));
        break;
      default:
        // Keep as is
        break;
    }
    
    return filtered.take(limit).toList();
  }
  
  static Map<String, dynamic> getMealPlan(String bmiCategory, DietGoal goal) {
    List<FoodItem> breakfast = [];
    List<FoodItem> lunch = [];
    List<FoodItem> dinner = [];
    List<FoodItem> snacks = [];
    
    // Simplified logic - you can make this more sophisticated
    for (var food in indianFoods) {
      if (food.suitableForBMI.contains(bmiCategory.toLowerCase())) {
        if (food.category.contains("Breakfast")) {
          breakfast.add(food);
        } else if (food.category.contains("Snacks")) {
          snacks.add(food);
        } else {
          // Randomly assign to lunch or dinner
          if (lunch.length < dinner.length) {
            lunch.add(food);
          } else {
            dinner.add(food);
          }
        }
      }
    }
    
    return {
      'breakfast': breakfast.take(2).toList(),
      'lunch': lunch.take(3).toList(),
      'snacks': snacks.take(2).toList(),
      'dinner': dinner.take(3).toList(),
    };
  }
  
  // Helper method to convert string to FoodCategory
  static FoodCategory? stringToFoodCategory(String category) {
    switch (category.toLowerCase()) {
      case 'vegetarian':
        return FoodCategory.vegetarian;
      case 'vegan':
        return FoodCategory.vegan;
      case 'nonvegetarian':
      case 'non-vegetarian':
        return FoodCategory.nonVegetarian;
      case 'eggetarian':
        return FoodCategory.eggetarian;
      case 'glutenfree':
      case 'gluten free':
        return FoodCategory.glutenFree;
      case 'dairyfree':
      case 'dairy free':
        return FoodCategory.dairyFree;
      case 'keto':
        return FoodCategory.keto;
      case 'lowcarb':
      case 'low carb':
        return FoodCategory.lowCarb;
      case 'highprotein':
      case 'high protein':
        return FoodCategory.highProtein;
      case 'lowfat':
      case 'low fat':
        return FoodCategory.lowFat;
      default:
        return null;
    }
  }
  
  // Helper method to convert string to DietGoal
  static DietGoal? stringToDietGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'weightloss':
      case 'weight loss':
        return DietGoal.weightLoss;
      case 'weightgain':
      case 'weight gain':
        return DietGoal.weightGain;
      case 'musclebuilding':
      case 'muscle building':
        return DietGoal.muscleBuilding;
      case 'maintenance':
        return DietGoal.maintenance;
      case 'healthimprovement':
      case 'health improvement':
        return DietGoal.healthImprovement;
      default:
        return null;
    }
  }
}