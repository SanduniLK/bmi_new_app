class FoodItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;
  final List<String> suitableForBMI;
  final List<String> dietaryTags;
  final List<String> mealType;
  final List<String> healthBenefits;
  final String? imageUrl;
  final bool isIndianFood;
  final int preparationTime;
  final List<String> ingredients;
  final List<String> recipeSteps;
  final double rating;
  final int reviewCount;
  final bool isPopular;
  final bool isRecommended;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    this.sugar = 0,
    this.sodium = 0,
    required this.suitableForBMI,
    required this.dietaryTags,
    required this.mealType,
    required this.healthBenefits,
    this.imageUrl,
    required this.isIndianFood,
    required this.preparationTime,
    required this.ingredients,
    this.recipeSteps = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.isPopular = false,
    this.isRecommended = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'suitableForBMI': suitableForBMI,
      'dietaryTags': dietaryTags,
      'mealType': mealType,
      'healthBenefits': healthBenefits,
      'imageUrl': imageUrl,
      'isIndianFood': isIndianFood,
      'preparationTime': preparationTime,
      'ingredients': ingredients,
      'recipeSteps': recipeSteps,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPopular': isPopular,
      'isRecommended': isRecommended,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json, String id) {
    return FoodItem(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      suitableForBMI: List<String>.from(json['suitableForBMI'] ?? []),
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      mealType: List<String>.from(json['mealType'] ?? []),
      healthBenefits: List<String>.from(json['healthBenefits'] ?? []),
      imageUrl: json['imageUrl'],
      isIndianFood: json['isIndianFood'] ?? false,
      preparationTime: json['preparationTime'] ?? 0,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      recipeSteps: List<String>.from(json['recipeSteps'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      isPopular: json['isPopular'] ?? false,
      isRecommended: json['isRecommended'] ?? false,
    );
  }

  // Helper methods for nutritional calculations
  double get caloriesPerGram => calories / 100;
  double get proteinPercentage => (protein * 4 / calories) * 100;
  double get carbsPercentage => (carbs * 4 / calories) * 100;
  double get fatsPercentage => (fats * 9 / calories) * 100;
  
  bool get isHighProtein => proteinPercentage > 30;
  bool get isLowCarb => carbsPercentage < 20;
  bool get isLowFat => fatsPercentage < 20;
  bool get isHighFiber => fiber > 5;
}

class MealPlan {
  final String id;
  final String name;
  final String description;
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;
  final List<FoodItem> snacks;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final String suitableForBMI;
  final List<String> dietaryTags;
  final String duration;

  MealPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.suitableForBMI,
    required this.dietaryTags,
    required this.duration,
  });

  factory MealPlan.fromFoods({
    required String id,
    required String name,
    required String description,
    required List<FoodItem> breakfast,
    required List<FoodItem> lunch,
    required List<FoodItem> dinner,
    required List<FoodItem> snacks,
    required String suitableForBMI,
    required List<String> dietaryTags,
    required String duration,
  }) {
    final allFoods = [...breakfast, ...lunch, ...dinner, ...snacks];
    final totalCalories = allFoods.fold(0.0, (sum, food) => sum + food.calories);
    final totalProtein = allFoods.fold(0.0, (sum, food) => sum + food.protein);
    final totalCarbs = allFoods.fold(0.0, (sum, food) => sum + food.carbs);
    final totalFats = allFoods.fold(0.0, (sum, food) => sum + food.fats);

    return MealPlan(
      id: id,
      name: name,
      description: description,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      suitableForBMI: suitableForBMI,
      dietaryTags: dietaryTags,
      duration: duration,
    );
  }
}