import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityLevel {
  sedentary('Sedentary', 'Little or no exercise', 1.2),
  lightlyActive('Lightly Active', 'Exercise 1-3 days/week', 1.375),
  moderatelyActive('Moderately Active', 'Exercise 3-5 days/week', 1.55),
  veryActive('Very Active', 'Exercise 6-7 days/week', 1.725),
  extremelyActive('Extremely Active', 'Athlete / Physical job', 1.9);

  final String label;
  final String description;
  final double factor;

  const ActivityLevel(this.label, this.description, this.factor);

  static ActivityLevel fromString(String? label) {
    if (label == null) return sedentary;
    for (var level in values) {
      if (level.label.toLowerCase() == label.toLowerCase()) {
        return level;
      }
    }
    return sedentary;
  }
}

class FoodEntry {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double servingSize;
  final String servingUnit;
  final DateTime timestamp;
  final String mealType;

  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    required this.servingUnit,
    required this.timestamp,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'timestamp': Timestamp.fromDate(timestamp),
      'mealType': mealType,
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json, String id) {
    return FoodEntry(
      id: id,
      name: json['name'] ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 1,
      servingUnit: json['servingUnit'] ?? 'serving',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mealType: json['mealType'] ?? 'snack',
    );
  }
}

class BMCCalculator {
  static Map<String, dynamic> getNutritionPlan(double tdee, String dietGoal) {
    double protein, carbs, fats;
    String recommendation;
    double calorieTarget = tdee;

    switch (dietGoal.toLowerCase()) {
      case 'weight loss':
        calorieTarget = tdee - 500;
        protein = (calorieTarget * 0.3 / 4);
        carbs = (calorieTarget * 0.4 / 4);
        fats = (calorieTarget * 0.3 / 9);
        recommendation = 'Create a calorie deficit of 300-500 calories daily for sustainable weight loss.';
        break;
      case 'weight gain':
        calorieTarget = tdee + 500;
        protein = (calorieTarget * 0.25 / 4);
        carbs = (calorieTarget * 0.5 / 4);
        fats = (calorieTarget * 0.25 / 9);
        recommendation = 'Aim for a calorie surplus of 300-500 calories with strength training for muscle gain.';
        break;
      case 'muscle building':
        calorieTarget = tdee + 300;
        protein = (calorieTarget * 0.35 / 4);
        carbs = (calorieTarget * 0.45 / 4);
        fats = (calorieTarget * 0.2 / 9);
        recommendation = 'Focus on protein intake and progressive overload in your workouts.';
        break;
      default:
        calorieTarget = tdee;
        protein = (calorieTarget * 0.3 / 4);
        carbs = (calorieTarget * 0.4 / 4);
        fats = (calorieTarget * 0.3 / 9);
        recommendation = 'Maintain your current calorie intake with balanced nutrition.';
    }

    return {
      'calorieTarget': calorieTarget.round(),
      'protein': protein.round(),
      'carbs': carbs.round(),
      'fats': fats.round(),
      'recommendation': recommendation,
    };
  }

  static String getBMRCategory(double bmr, String gender) {
    if (gender.toLowerCase() == 'male') {
      if (bmr < 1400) return 'Very Low';
      if (bmr < 1600) return 'Low';
      if (bmr < 1900) return 'Normal';
      if (bmr < 2200) return 'High';
      return 'Very High';
    } else {
      if (bmr < 1200) return 'Very Low';
      if (bmr < 1400) return 'Low';
      if (bmr < 1700) return 'Normal';
      if (bmr < 2000) return 'High';
      return 'Very High';
    }
  }
}

// Common foods database
class FoodDatabase {
  static final List<Map<String, dynamic>> commonFoods = [
    {
      'name': 'Apple',
      'calories': 95,
      'protein': 0.5,
      'carbs': 25,
      'fats': 0.3,
      'servingSize': 1,
      'servingUnit': 'medium',
    },
    {
      'name': 'Banana',
      'calories': 105,
      'protein': 1.3,
      'carbs': 27,
      'fats': 0.4,
      'servingSize': 1,
      'servingUnit': 'medium',
    },
    {
      'name': 'Chicken Breast',
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fats': 3.6,
      'servingSize': 100,
      'servingUnit': 'g',
    },
    {
      'name': 'Rice (Cooked)',
      'calories': 130,
      'protein': 2.7,
      'carbs': 28,
      'fats': 0.3,
      'servingSize': 100,
      'servingUnit': 'g',
    },
    {
      'name': 'Egg',
      'calories': 78,
      'protein': 6.3,
      'carbs': 0.6,
      'fats': 5.3,
      'servingSize': 1,
      'servingUnit': 'large',
    },
    {
      'name': 'Oatmeal',
      'calories': 150,
      'protein': 5,
      'carbs': 27,
      'fats': 2.5,
      'servingSize': 40,
      'servingUnit': 'g',
    },
    {
      'name': 'Salmon',
      'calories': 208,
      'protein': 20,
      'carbs': 0,
      'fats': 13,
      'servingSize': 100,
      'servingUnit': 'g',
    },
    {
      'name': 'Broccoli',
      'calories': 55,
      'protein': 3.7,
      'carbs': 11,
      'fats': 0.6,
      'servingSize': 100,
      'servingUnit': 'g',
    },
    {
      'name': 'Greek Yogurt',
      'calories': 100,
      'protein': 10,
      'carbs': 3.6,
      'fats': 5,
      'servingSize': 100,
      'servingUnit': 'g',
    },
    {
      'name': 'Almonds',
      'calories': 164,
      'protein': 6,
      'carbs': 6,
      'fats': 14,
      'servingSize': 28,
      'servingUnit': 'g',
    },
  ];
}