import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/food_model.dart';
import '../services/food_service.dart';
import '../services/storage_service.dart';
import '../services/admin_service.dart';
import '../utils/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminFoodScreen extends StatefulWidget {
  const AdminFoodScreen({super.key});

  @override
  State<AdminFoodScreen> createState() => _AdminFoodScreenState();
}

class _AdminFoodScreenState extends State<AdminFoodScreen> with TickerProviderStateMixin {
  final FoodService _foodService = FoodService();
  final StorageService _storageService = StorageService();
  final AdminService _adminService = AdminService();
  
  bool _isAdmin = false;
  bool _isLoading = true;
  List<FoodItem> _foods = [];
  User? _currentUser;
  
  late AnimationController _refreshController;

  // List of admin emails (hardcoded for security)
  final List<String> _adminEmails = [
    'ab@gmail.com',
    'admin@bmi-app.com',
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    
    if (_currentUser != null) {
      // Check if user email is in admin list
      _isAdmin = _adminEmails.contains(_currentUser!.email?.toLowerCase());
      
      setState(() {
        _isAdmin = _isAdmin;
        _isLoading = false;
      });
      
      if (_isAdmin) {
        _loadFoods();
      }
    } else {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  void _loadFoods() {
    _foodService.getAllFoods().listen((foods) {
      if (mounted) {
        setState(() {
          _foods = foods;
        });
        _refreshController.forward().then((_) => _refreshController.reverse());
      }
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Access Denied'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 100, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                const Text(
                  'Admin Access Required',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'You do not have permission to access this page.\n\nOnly specific admin accounts can manage food items.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                if (_currentUser != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Logged in as:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser?.email ?? 'Unknown',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This account does not have admin privileges.',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin - Food Management').animate().fadeIn(duration: 500.ms),
            Text(
              'Admin: ${_currentUser?.email}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFoods,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await _logout();
              }
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _refreshController,
        builder: (context, child) {
          return RefreshIndicator(
            onRefresh: () async {
              _loadFoods();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _foods.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddCard();
                }
                return _buildFoodCard(_foods[index - 1]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditFoodDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAddCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showAddEditFoodDialog(),
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, color: AppColors.primary, size: 30),
              SizedBox(width: 10),
              Text(
                'Add New Food Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              food.calories.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${food.calories} kcal | ${food.protein}g protein',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
              onPressed: () => _showAddEditFoodDialog(food: food),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(food),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Description', food.description),
                _buildInfoRow('Category', food.category),
                _buildInfoRow('Meal Type', food.mealType.join(', ')),
                _buildInfoRow('Dietary Tags', food.dietaryTags.join(', ')),
                _buildInfoRow('Suitable for BMI', food.suitableForBMI.join(', ')),
                _buildInfoRow('Health Benefits', food.healthBenefits.join(', ')),
                _buildInfoRow('Ingredients', food.ingredients.join(', ')),
                _buildInfoRow('Preparation Time', '${food.preparationTime} mins'),
                _buildInfoRow('Rating', '${food.rating} ⭐ (${food.reviewCount} reviews)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEditFoodDialog({FoodItem? food}) async {
    final isEditing = food != null;
    final formKey = GlobalKey<FormState>();
    
    // Controllers
    final nameController = TextEditingController(text: food?.name ?? '');
    final descriptionController = TextEditingController(text: food?.description ?? '');
    final categoryController = TextEditingController(text: food?.category ?? '');
    final caloriesController = TextEditingController(text: food?.calories.toString() ?? '');
    final proteinController = TextEditingController(text: food?.protein.toString() ?? '');
    final carbsController = TextEditingController(text: food?.carbs.toString() ?? '');
    final fatsController = TextEditingController(text: food?.fats.toString() ?? '');
    final fiberController = TextEditingController(text: food?.fiber.toString() ?? '');
    final sugarController = TextEditingController(text: food?.sugar.toString() ?? '');
    final sodiumController = TextEditingController(text: food?.sodium.toString() ?? '');
    final prepTimeController = TextEditingController(text: food?.preparationTime.toString() ?? '');
    final ratingController = TextEditingController(text: food?.rating.toString() ?? '4.0');
    final reviewCountController = TextEditingController(text: food?.reviewCount.toString() ?? '0');
    
    // Lists
    final mealTypes = List<String>.from(food?.mealType ?? []);
    final dietaryTags = List<String>.from(food?.dietaryTags ?? []);
    final suitableForBMI = List<String>.from(food?.suitableForBMI ?? []);
    final healthBenefits = List<String>.from(food?.healthBenefits ?? []);
    final ingredients = List<String>.from(food?.ingredients ?? []);
    
    // Image
    File? selectedImage;
    String? imageUrl = food?.imageUrl;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Food' : 'Add New Food'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: selectedImage == null && imageUrl == null
                          ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(nameController, 'Food Name', Icons.fastfood),
                  _buildTextField(descriptionController, 'Description', Icons.description, maxLines: 3),
                  _buildTextField(categoryController, 'Category (e.g., Vegetarian)', Icons.category),
                  _buildTextField(caloriesController, 'Calories', Icons.local_fire_department, isNumber: true),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(proteinController, 'Protein (g)', Icons.fitness_center, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTextField(carbsController, 'Carbs (g)', Icons.bolt, isNumber: true)),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(fatsController, 'Fats (g)', Icons.oil_barrel, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTextField(fiberController, 'Fiber (g)', Icons.grass, isNumber: true)),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(sugarController, 'Sugar (g)', Icons.cake, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTextField(sodiumController, 'Sodium (mg)', Icons.water, isNumber: true)),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(prepTimeController, 'Prep Time (min)', Icons.timer, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTextField(ratingController, 'Rating (0-5)', Icons.star, isNumber: true)),
                    ],
                  ),
                  
                  _buildTextField(reviewCountController, 'Review Count', Icons.reviews, isNumber: true),
                  
                  const SizedBox(height: 16),
                  
                  // Multi-select sections
                  _buildTagSection('Meal Types', mealTypes, ['Breakfast', 'Lunch', 'Dinner', 'Snacks'], setState),
                  _buildTagSection('Dietary Tags', dietaryTags, ['Vegetarian', 'Vegan', 'Gluten-Free', 'Keto', 'High Protein'], setState),
                  _buildTagSection('Suitable for BMI', suitableForBMI, ['underweight', 'normal', 'overweight', 'obese'], setState),
                  _buildTagSection('Health Benefits', healthBenefits, [], setState),
                  _buildTagSection('Ingredients', ingredients, [], setState),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Upload image if selected
                  String? uploadedImageUrl = imageUrl;
                  if (selectedImage != null) {
                    uploadedImageUrl = await _storageService.uploadFoodImage(selectedImage!);
                  }

                  final newFood = FoodItem(
                    id: food?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    description: descriptionController.text,
                    category: categoryController.text,
                    calories: double.parse(caloriesController.text),
                    protein: double.parse(proteinController.text),
                    carbs: double.parse(carbsController.text),
                    fats: double.parse(fatsController.text),
                    fiber: double.parse(fiberController.text),
                    sugar: double.parse(sugarController.text),
                    sodium: double.parse(sodiumController.text),
                    suitableForBMI: suitableForBMI,
                    dietaryTags: dietaryTags,
                    mealType: mealTypes,
                    healthBenefits: healthBenefits,
                    imageUrl: uploadedImageUrl,
                    isIndianFood: false,
                    preparationTime: int.parse(prepTimeController.text),
                    ingredients: ingredients,
                    recipeSteps: const [],
                    rating: double.parse(ratingController.text),
                    reviewCount: int.parse(reviewCountController.text),
                    isPopular: false,
                    isRecommended: false,
                  );

                  try {
                    if (isEditing) {
                      await _foodService.updateFood(newFood);
                    } else {
                      await _foodService.addFood(newFood);
                    }
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Food updated!' : 'Food added!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTagSection(String title, List<String> selectedTags, List<String> options, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ...options.map((option) {
                final isSelected = selectedTags.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTags.add(option);
                      } else {
                        selectedTags.remove(option);
                      }
                    });
                  },
                );
              }),
              if (title == 'Ingredients' || title == 'Health Benefits')
                TextButton.icon(
                  onPressed: () => _showAddCustomTagDialog(title, selectedTags, setState),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCustomTagDialog(String title, List<String> tags, StateSetter setState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  tags.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(FoodItem food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food'),
        content: Text('Are you sure you want to delete "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _foodService.deleteFood(food.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Food deleted!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}