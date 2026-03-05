import 'package:bmi_new_app/screens/food_detail_screen.dart';
import 'package:bmi_new_app/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/food_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/food_card.dart';

class FoodRecommendationsScreen extends StatefulWidget {
  const FoodRecommendationsScreen({super.key});

  @override
  State<FoodRecommendationsScreen> createState() => _FoodRecommendationsScreenState();
}

class _FoodRecommendationsScreenState extends State<FoodRecommendationsScreen> {
  final FoodService _foodService = FoodService();
  
  String _selectedCategory = 'All';
  String _selectedMealType = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  
  final List<String> _categories = [
    'All', 'Vegetarian', 'Non-Vegetarian', 'Vegan', 'Indian'
  ];
  
  final List<String> _mealTypes = [
    'All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'
  ];

  AppUser? _currentUser;
  List<FoodItem> _recommendations = [];
  List<FoodItem> _popularFoods = [];
  MealPlan? _personalizedPlan;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestoreService = FirestoreService();
      final userData = await firestoreService.getAppUser(user.uid);
      
      if (mounted && userData != null) {
        setState(() {
          _currentUser = userData;
        });
        
        _loadRecommendations(userData);
        _loadPopularFoods();
        _loadMealPlan(userData);
      } else {
        // Create default user if not found
        final defaultUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          dietGoal: 'maintenance',
          foodPreferences: const [],
          createdAt: DateTime.now(),
        );
        
        setState(() {
          _currentUser = defaultUser;
        });
        
        _loadRecommendations(defaultUser);
        _loadPopularFoods();
        _loadMealPlan(defaultUser);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _loadRecommendations(AppUser user) {
    _foodService.getPersonalizedRecommendations(user).listen((foods) {
      if (mounted) {
        setState(() {
          _recommendations = foods;
          _isLoading = false;
        });
      }
    });
  }

  void _loadPopularFoods() {
    _foodService.getPopularFoods().listen((foods) {
      if (mounted) {
        setState(() {
          _popularFoods = foods;
        });
      }
    });
  }

  Future<void> _loadMealPlan(AppUser user) async {
    final plan = await _foodService.getPersonalizedMealPlan(user);
    if (mounted) {
      setState(() {
        _personalizedPlan = plan;
      });
    }
  }

  List<FoodItem> get _filteredFoods {
    var foods = _recommendations;
    
    // Apply category filter
    if (_selectedCategory != 'All') {
      foods = foods.where((f) => 
        f.category.contains(_selectedCategory)).toList();
    }
    
    // Apply meal type filter
    if (_selectedMealType != 'All') {
      foods = foods.where((f) => 
        f.mealType.contains(_selectedMealType)).toList();
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      foods = foods.where((f) =>
        f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        f.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        f.dietaryTags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    
    return foods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recommendations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (_currentUser != null) {
                  _loadRecommendations(_currentUser!);
                  _loadPopularFoods();
                  _loadMealPlan(_currentUser!);
                }
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personalized Meal Plan Banner
                    if (_personalizedPlan != null)
                      _buildMealPlanBanner(),
                    
                    const SizedBox(height: 24),

                    // Category Filters
                    _buildSectionHeader('Categories'),
                    const SizedBox(height: 12),
                    _buildCategoryFilters(),
                    
                    const SizedBox(height: 24),

                    // Meal Type Filters
                    _buildSectionHeader('Meal Type'),
                    const SizedBox(height: 12),
                    _buildMealTypeFilters(),
                    
                    const SizedBox(height: 24),

                    // Popular Foods
                    if (_popularFoods.isNotEmpty) ...[
                      _buildSectionHeader('Popular Choices'),
                      const SizedBox(height: 12),
                      _buildPopularFoods(),
                    ],
                    
                    const SizedBox(height: 24),

                    // Recommended Foods
                    _buildSectionHeader('Recommended for You'),
                    const SizedBox(height: 12),
                    if (_filteredFoods.isEmpty)
                      _buildEmptyState()
                    else
                      _buildFoodGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (title == 'Recommended for You' && _recommendations.length > 6)
          TextButton(
            onPressed: () {
              // TODO: Navigate to all recommendations
            },
            child: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealTypeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _mealTypes.map((type) {
          final isSelected = _selectedMealType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMealType = type;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularFoods() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularFoods.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: FoodCard(
              food: _popularFoods[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailScreen(food: _popularFoods[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredFoods.length > 6 ? 6 : _filteredFoods.length,
      itemBuilder: (context, index) {
        return FoodCard(
          food: _filteredFoods[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(food: _filteredFoods[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealPlanBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealPlanScreen(mealPlan: _personalizedPlan!),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Personalized Meal Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on your BMI and preferences',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_personalizedPlan!.totalCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No foods found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}