import 'package:bmi_new_app/screens/login_screen.dart';
import 'package:bmi_new_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_picture.dart';


class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  final Function? toggleView; 
  
  const EditProfileScreen({super.key, required this.user, this.toggleView});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _allergiesController;
  
  // Selected values
  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedDietGoal;
  List<String> _selectedFoodPreferences = [];
  
  // Profile image
  String? _profileImageUrl;
  
  // Loading state
  bool _isLoading = false;  // This changes, so can't be final
  bool _isSaving = false;
  
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _ageController = TextEditingController(text: widget.user.age?.toString() ?? '');
    _weightController = TextEditingController(text: widget.user.weight?.toString() ?? '');
    _heightController = TextEditingController(text: widget.user.height?.toString() ?? '');
    _allergiesController = TextEditingController(
      text: widget.user.allergies?.join(', ') ?? ''
    );
    
    _selectedGender = widget.user.gender;
    _selectedActivityLevel = widget.user.activityLevel;
    _selectedDietGoal = widget.user.dietGoal;
    _selectedFoodPreferences = List.from(widget.user.foodPreferences ?? []);
    _profileImageUrl = widget.user.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  // Fix line 68 - Replace ?. with . if the receiver can't be null
  // Example: If you have something like "user?.name", change to "user.name"
  // You need to check your actual code at line 68

  // Remove dead code at line 74 if it exists

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    Center(
                      child: ProfilePicture(
                        initialImageUrl: _profileImageUrl,
                        size: 120,
                        onImageUploaded: (url) {
                          setState(() {
                            _profileImageUrl = url;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // Personal Information Section
                    _buildSectionHeader('Personal Information'),
                    const SizedBox(height: 16),
                    
                    // Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (read-only)
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Age and Gender Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGenderDropdown(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weight and Height Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Weight (kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Height (cm)',
                            icon: Icons.height_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // Lifestyle Section
                    _buildSectionHeader('Lifestyle & Goals'),
                    const SizedBox(height: 16),

                    // Activity Level
                    _buildActivityLevelDropdown(),
                    const SizedBox(height: 16),

                    // Diet Goal
                    _buildDietGoalDropdown(),
                    
                    const SizedBox(height: 30),

                    // Dietary Preferences Section
                    _buildSectionHeader('Dietary Preferences'),
                    const SizedBox(height: 16),

                    // Food Preferences
                    _buildFoodPreferencesSection(),
                    const SizedBox(height: 16),

                    // Allergies
                    _buildTextField(
                      controller: _allergiesController,
                      label: 'Allergies (comma separated)',
                      icon: Icons.warning_amber_outlined,
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 30),

                    // Save Button
                    if (_isSaving)
                      const Center(child: CircularProgressIndicator())
                    else
                      CustomButton(
                        text: 'Save Changes',
                        onPressed: _saveProfile,
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Logout Button - FIXED (Line 283)
                    CustomButton(
                      text: "Log Out",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  try {
                                    await FirebaseAuth.instance.signOut();
                                    if (context.mounted) {
                                      // FIXED: No const, no null
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(
                                            toggleView: () {
                                              // Navigate to register screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RegisterScreen(
                                                    toggleView: () {
                                                      // This can be empty or handle navigation back
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      color: Colors.red,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // ... rest of your helper methods remain the same
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade50 : null,
      ),
      validator: validator,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildActivityLevelDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedActivityLevel,
      decoration: InputDecoration(
        labelText: 'Activity Level',
        prefixIcon: Icon(Icons.directions_run_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Sedentary', child: Text('Sedentary (Little/No Exercise)')),
        DropdownMenuItem(value: 'Lightly Active', child: Text('Lightly Active (1-3 days/week)')),
        DropdownMenuItem(value: 'Moderately Active', child: Text('Moderately Active (3-5 days/week)')),
        DropdownMenuItem(value: 'Very Active', child: Text('Very Active (6-7 days/week)')),
        DropdownMenuItem(value: 'Extremely Active', child: Text('Extremely Active (Athlete)')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedActivityLevel = value;
        });
      },
    );
  }

  Widget _buildDietGoalDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDietGoal,
      decoration: InputDecoration(
        labelText: 'Diet Goal',
        prefixIcon: Icon(Icons.flag_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Weight Loss', child: Text('Weight Loss')),
        DropdownMenuItem(value: 'Weight Gain', child: Text('Weight Gain')),
        DropdownMenuItem(value: 'Muscle Building', child: Text('Muscle Building')),
        DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
        DropdownMenuItem(value: 'Overall Health', child: Text('Overall Health')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedDietGoal = value;
        });
      },
    );
  }

  Widget _buildFoodPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Preferences',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Vegetarian', 'Vegan', 'Non-Vegetarian', 'Eggetarian',
            'Keto', 'Low Carb', 'High Protein', 'Mediterranean',
            'Paleo', 'Gluten-Free', 'Dairy-Free'
          ].map((pref) {
            final isSelected = _selectedFoodPreferences.contains(pref);
            return FilterChip(
              label: Text(pref),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFoodPreferences.add(pref);
                  } else {
                    _selectedFoodPreferences.remove(pref);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text),
        'weight': double.tryParse(_weightController.text),
        'height': int.tryParse(_heightController.text),
        'gender': _selectedGender,
        'activityLevel': _selectedActivityLevel,
        'dietGoal': _selectedDietGoal,
        'foodPreferences': _selectedFoodPreferences,
        'allergies': _allergiesController.text.isNotEmpty
            ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        'photoURL': _profileImageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      updatedData.removeWhere((key, value) => value == null);

      await _firebaseService.updateUserProfile(user.uid, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}