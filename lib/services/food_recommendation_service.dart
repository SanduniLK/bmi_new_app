import '../models/food_model.dart';
import '../models/user_model.dart';

class FoodRecommendationService {
  
  // Sample food database (in production, this would come from Firestore)
  static final List<FoodItem> _foodDatabase = [
    // High Protein Foods
    FoodItem(
      id: '1',
      name: 'Grilled Chicken Breast',
      description: 'Lean protein source, perfect for muscle building',
      category: 'Non-Vegetarian',
      calories: 165,
      protein: 31,
      carbs: 0,
      fats: 3.6,
      fiber: 0,
      sugar: 0,
      sodium: 74,
      suitableForBMI: ['underweight', 'normal', 'overweight'],
      dietaryTags: ['High Protein', 'Low Carb', 'Keto', 'Paleo'],
      mealType: ['Lunch', 'Dinner'],
      healthBenefits: ['Muscle building', 'Weight management', 'Bone health'],
      imageUrl: 'assets/images/chicken.jpg',
      isIndianFood: false,
      preparationTime: 20,
      ingredients: ['Chicken breast', 'Olive oil', 'Spices'],
      recipeSteps: [
        'Marinate chicken with spices',
        'Grill for 6-7 minutes each side',
        'Rest for 5 minutes before serving'
      ],
      rating: 4.5,
      reviewCount: 128,
      isPopular: true,
    ),
    
    FoodItem(
      id: '2',
      name: 'Paneer Tikka',
      description: 'Indian cottage cheese marinated in spices',
      category: 'Vegetarian',
      calories: 280,
      protein: 18,
      carbs: 8,
      fats: 20,
      fiber: 1,
      sugar: 2,
      sodium: 450,
      suitableForBMI: ['underweight', 'normal'],
      dietaryTags: ['High Protein', 'Vegetarian', 'Indian'],
      mealType: ['Snacks', 'Dinner'],
      healthBenefits: ['Muscle building', 'Calcium rich', 'Bone health'],
      imageUrl: 'assets/images/paneer_tikka.jpg',
      isIndianFood: true,
      preparationTime: 30,
      ingredients: ['Paneer', 'Yogurt', 'Spices', 'Bell peppers'],
      recipeSteps: [
        'Marinate paneer with yogurt and spices',
        'Skewer with vegetables',
        'Grill or bake until golden'
      ],
      rating: 4.7,
      reviewCount: 95,
      isPopular: true,
    ),

    // Low Calorie Foods
    FoodItem(
      id: '3',
      name: 'Quinoa Salad',
      description: 'Protein-rich grain salad with vegetables',
      category: 'Vegan',
      calories: 220,
      protein: 8,
      carbs: 39,
      fats: 3.5,
      fiber: 5,
      sugar: 2,
      sodium: 150,
      suitableForBMI: ['overweight', 'obese', 'normal'],
      dietaryTags: ['Vegan', 'Gluten-Free', 'High Fiber'],
      mealType: ['Lunch', 'Dinner'],
      healthBenefits: ['Weight loss', 'Digestive health', 'Energy'],
      imageUrl: 'assets/images/quinoa_salad.jpg',
      isIndianFood: false,
      preparationTime: 15,
      ingredients: ['Quinoa', 'Cucumber', 'Tomatoes', 'Lemon juice'],
      recipeSteps: [
        'Cook quinoa according to package',
        'Chop vegetables',
        'Mix all ingredients with lemon dressing'
      ],
      rating: 4.3,
      reviewCount: 67,
    ),

    FoodItem(
      id: '4',
      name: 'Vegetable Soup',
      description: 'Light and nutritious vegetable soup',
      category: 'Vegan',
      calories: 80,
      protein: 3,
      carbs: 15,
      fats: 1,
      fiber: 4,
      sugar: 5,
      sodium: 350,
      suitableForBMI: ['overweight', 'obese', 'normal'],
      dietaryTags: ['Vegan', 'Low Calorie', 'Low Fat'],
      mealType: ['Dinner', 'Snacks'],
      healthBenefits: ['Weight loss', 'Hydration', 'Vitamins'],
      imageUrl: 'assets/images/vegetable_soup.jpg',
      isIndianFood: false,
      preparationTime: 25,
      ingredients: ['Mixed vegetables', 'Vegetable broth', 'Herbs'],
      recipeSteps: [
        'Sauté vegetables',
        'Add broth and simmer',
        'Blend for smooth soup'
      ],
      rating: 4.1,
      reviewCount: 42,
    ),

    // Energy Foods (for underweight)
    FoodItem(
      id: '5',
      name: 'Peanut Butter Banana Smoothie',
      description: 'High calorie, protein-rich smoothie',
      category: 'Vegan',
      calories: 400,
      protein: 15,
      carbs: 45,
      fats: 18,
      fiber: 5,
      sugar: 20,
      sodium: 120,
      suitableForBMI: ['underweight', 'normal'],
      dietaryTags: ['High Protein', 'Vegan', 'Gluten-Free'],
      mealType: ['Breakfast', 'Snacks'],
      healthBenefits: ['Weight gain', 'Energy boost', 'Muscle recovery'],
      imageUrl: 'assets/images/smoothie.jpg',
      isIndianFood: false,
      preparationTime: 5,
      ingredients: ['Banana', 'Peanut butter', 'Milk', 'Protein powder'],
      recipeSteps: [
        'Add all ingredients to blender',
        'Blend until smooth',
        'Serve immediately'
      ],
      rating: 4.6,
      reviewCount: 83,
      isPopular: true,
    ),

    // Indian Foods
    FoodItem(
      id: '6',
      name: 'Dal Makhani',
      description: 'Creamy black lentils, protein-rich',
      category: 'Vegetarian',
      calories: 310,
      protein: 14,
      carbs: 35,
      fats: 12,
      fiber: 8,
      sugar: 3,
      sodium: 520,
      suitableForBMI: ['underweight', 'normal', 'overweight'],
      dietaryTags: ['Vegetarian', 'High Protein', 'High Fiber', 'Indian'],
      mealType: ['Lunch', 'Dinner'],
      healthBenefits: ['Digestive health', 'Heart health', 'Energy'],
      imageUrl: 'assets/images/dal_makhani.jpg',
      isIndianFood: true,
      preparationTime: 40,
      ingredients: ['Black lentils', 'Kidney beans', 'Cream', 'Spices'],
      recipeSteps: [
        'Soak lentils overnight',
        'Pressure cook with spices',
        'Simmer with cream and butter'
      ],
      rating: 4.8,
      reviewCount: 156,
      isPopular: true,
    ),

    FoodItem(
      id: '7',
      name: 'Chicken Biryani',
      description: 'Fragrant rice dish with spiced chicken',
      category: 'Non-Vegetarian',
      calories: 550,
      protein: 25,
      carbs: 65,
      fats: 20,
      fiber: 2,
      sugar: 2,
      sodium: 680,
      suitableForBMI: ['underweight', 'normal'],
      dietaryTags: ['High Protein', 'Non-Vegetarian', 'Indian'],
      mealType: ['Lunch', 'Dinner'],
      healthBenefits: ['Muscle building', 'Energy', 'Tasty'],
      imageUrl: 'assets/images/biryani.jpg',
      isIndianFood: true,
      preparationTime: 60,
      ingredients: ['Chicken', 'Rice', 'Yogurt', 'Biryani masala'],
      recipeSteps: [
        'Marinate chicken with yogurt and spices',
        'Cook rice partially',
        'Layer chicken and rice, cook on low heat'
      ],
      rating: 4.9,
      reviewCount: 234,
      isPopular: true,
    ),

    FoodItem(
      id: '8',
      name: 'Masala Dosa',
      description: 'Crispy fermented crepe with potato filling',
      category: 'Vegetarian',
      calories: 250,
      protein: 6,
      carbs: 40,
      fats: 8,
      fiber: 3,
      sugar: 1,
      sodium: 420,
      suitableForBMI: ['normal', 'overweight'],
      dietaryTags: ['Vegetarian', 'Fermented', 'Indian'],
      mealType: ['Breakfast', 'Dinner'],
      healthBenefits: ['Digestive health', 'Probiotic', 'Light meal'],
      imageUrl: 'assets/images/dosa.jpg',
      isIndianFood: true,
      preparationTime: 20,
      ingredients: ['Rice', 'Urad dal', 'Potato', 'Spices'],
      recipeSteps: [
        'Ferment rice and dal batter',
        'Prepare potato masala',
        'Spread batter on hot griddle, add filling'
      ],
      rating: 4.6,
      reviewCount: 178,
    ),
  ];

  // Get personalized recommendations based on user profile
  static List<FoodItem> getPersonalizedRecommendations({
    required AppUser user,
    int limit = 10,
  }) {
    final bmiCategory = user.getBMICategory() ?? 'normal';
    final preferences = user.foodPreferences;
    final dietGoal = user.dietGoal?.toLowerCase() ?? 'maintenance';
    
    // Score each food item based on user profile
    final scoredFoods = _foodDatabase.map((food) {
      int score = 0;
      
      // BMI suitability (highest weight)
      if (food.suitableForBMI.contains(bmiCategory.toLowerCase())) {
        score += 30;
      }
      
      // Dietary preferences match
      if (preferences != null) {
        if (food.dietaryTags.any((tag) => 
            preferences.any((pref) => tag.toLowerCase().contains(pref.toLowerCase())))) {
          score += 20;
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
        case 'maintenance':
          if (food.calories >= 300 && food.calories <= 500) score += 10;
          break;
      }
      
      // Popular items get a boost
      if (food.isPopular) score += 5;
      if (food.rating > 4.5) score += 5;
      
      return {'food': food, 'score': score};
    }).toList();
    
    // Sort by score and return top items
    scoredFoods.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return scoredFoods.take(limit).map((item) => item['food'] as FoodItem).toList();
  }

  // Get meal plan based on user profile
  static MealPlan getPersonalizedMealPlan(AppUser user) {
    final bmiCategory = user.getBMICategory() ?? 'normal';
    final preferences = user.foodPreferences;
    final dietGoal = user.dietGoal?.toLowerCase() ?? 'maintenance';
    
    // Filter foods by BMI category
    final suitableFoods = _foodDatabase.where((food) =>
        food.suitableForBMI.contains(bmiCategory.toLowerCase())).toList();
    
    // Further filter by dietary preferences if any
    List<FoodItem> availableFoods;
    if (preferences != null && preferences.isNotEmpty) {
      availableFoods = suitableFoods.where((food) =>
          food.dietaryTags.any((tag) =>
              preferences.any((pref) => tag.toLowerCase().contains(pref.toLowerCase()))))
        .toList();
    } else {
      availableFoods = suitableFoods;
    }
    
    // Use preferred foods if available, otherwise fall back to suitable foods
    if (availableFoods.isEmpty) {
      availableFoods = suitableFoods;
    }
    
    // Categorize by meal type
    final breakfastOptions = availableFoods.where((f) => f.mealType.contains('Breakfast')).toList();
    final lunchOptions = availableFoods.where((f) => f.mealType.contains('Lunch')).toList();
    final dinnerOptions = availableFoods.where((f) => f.mealType.contains('Dinner')).toList();
    final snackOptions = availableFoods.where((f) => f.mealType.contains('Snacks')).toList();
    
    // Select items based on diet goal
    List<FoodItem> selectFoods(List<FoodItem> options, int count) {
      if (options.isEmpty) return [];
      
      List<FoodItem> sorted = List.from(options);
      
      switch (dietGoal) {
        case 'weight loss':
          sorted.sort((a, b) => a.calories.compareTo(b.calories));
          break;
        case 'weight gain':
        case 'muscle building':
          sorted.sort((a, b) => b.protein.compareTo(a.protein));
          break;
        default:
          // Keep as is or sort by rating
          sorted.sort((a, b) => b.rating.compareTo(a.rating));
      }
      
      return sorted.take(count).toList();
    }
    
    return MealPlan.fromFoods(
      id: 'personalized_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Your Personalized Meal Plan',
      description: 'Based on your BMI: $bmiCategory',
      breakfast: selectFoods(breakfastOptions, 2),
      lunch: selectFoods(lunchOptions, 3),
      dinner: selectFoods(dinnerOptions, 3),
      snacks: selectFoods(snackOptions, 2),
      suitableForBMI: bmiCategory,
      dietaryTags: preferences ?? [],
      duration: '1 day',
    );
  }

  // Get foods by category
  static List<FoodItem> getFoodsByCategory(String category) {
    return _foodDatabase.where((food) => 
      food.category.toLowerCase().contains(category.toLowerCase())).toList();
  }

  // Search foods
  static List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) return [];
    
    return _foodDatabase.where((food) =>
      food.name.toLowerCase().contains(query.toLowerCase()) ||
      food.description.toLowerCase().contains(query.toLowerCase()) ||
      food.dietaryTags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // Get popular foods
  static List<FoodItem> getPopularFoods({int limit = 5}) {
    return _foodDatabase.where((food) => food.isPopular)
        .toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Get foods by BMI category
  static List<FoodItem> getFoodsByBMI(String bmiCategory) {
    return _foodDatabase.where((food) =>
        food.suitableForBMI.contains(bmiCategory.toLowerCase())).toList();
  }

  // Get nutritional advice based on BMI and goal
  static String getNutritionalAdvice(AppUser user) {
    final bmi = user.calculateBMI();
    final goal = user.dietGoal?.toLowerCase() ?? 'maintenance';
    
    if (bmi == null) return 'Track your BMI to get personalized advice.';
    
    if (bmi < 18.5) {
      return 'Focus on calorie-dense, nutrient-rich foods. Include healthy fats like nuts, avocados, and full-fat dairy. Add protein shakes between meals.';
    } else if (bmi < 25) {
      if (goal == 'weight loss') {
        return 'Maintain your healthy weight with balanced meals. Focus on portion control and include plenty of vegetables.';
      } else if (goal == 'muscle building') {
        return 'Increase protein intake to support muscle growth. Include lean meats, eggs, and legumes in your meals.';
      } else {
        return 'Great job! Continue with balanced meals including proteins, healthy fats, and complex carbs.';
      }
    } else if (bmi < 30) {
      return 'Focus on low-calorie, high-fiber foods. Include plenty of vegetables, lean proteins, and whole grains. Limit processed foods and sugary drinks.';
    } else {
      return 'Consult with a healthcare provider. Focus on whole foods, portion control, and regular physical activity. Aim for gradual, sustainable weight loss.';
    }
  }
}