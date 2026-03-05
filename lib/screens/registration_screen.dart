import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_storage_service.dart';
import 'food_preferences_screen.dart';
import 'user_dashboard.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  
  String _selectedGoal = 'Maintenance';
  
  final List<String> _selectedPreferences = [];
  final List<String> _allergies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Your Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Age and Gender Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Select gender';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Weight and Height Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Diet Goal
              const Text(
                'Your Diet Goal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Weight Loss', 'Weight Gain', 'Muscle Building', 
                  'Maintenance', 'Health Improvement'
                ].map((goal) {
                  return ChoiceChip(
                    label: Text(goal),
                    selected: _selectedGoal == goal,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGoal = goal;
                      });
                    },
                    selectedColor: Colors.deepPurple.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Food Preferences Button
              ElevatedButton.icon(
                onPressed: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodPreferencesScreen(
                        selectedPreferences: _selectedPreferences,
                      ),
                    ),
                  );
                  
                  if (selected != null) {
                    setState(() {
                      _selectedPreferences.clear();
                      _selectedPreferences.addAll(selected as List<String>);
                    });
                  }
                },
                icon: const Icon(Icons.restaurant_menu),
                label: Text(
                  _selectedPreferences.isEmpty
                      ? 'Select Food Preferences'
                      : '${_selectedPreferences.length} Foods Selected',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              
              if (_selectedPreferences.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _selectedPreferences.map((pref) {
                    return Chip(
                      label: Text(pref),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedPreferences.remove(pref);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Allergies
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Allergies (comma separated)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.warning),
                  hintText: 'e.g., peanuts, lactose, gluten',
                ),
                onChanged: (value) {
                  _allergies.clear();
                  if (value.isNotEmpty) {
                    _allergies.addAll(value.split(',').map((e) => e.trim()));
                  }
                },
              ),
              
              const SizedBox(height: 30),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register & Continue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender')),
        );
        return;
      }
      
      if (_selectedPreferences.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select food preferences')),
        );
        return;
      }
      
      // Create user object with Firestore-compatible field names
      AppUser user = AppUser(
        uid: '', // Will be set by Firebase
        email: '', // Will be set by Firebase
        name: _nameController.text,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: int.parse(_heightController.text),
        gender: _selectedGender!,
        foodPreferences: _selectedPreferences,
        dietGoal: _selectedGoal,
        activityLevel: null,
        allergies: _allergies,
        photoURL: null,
        createdAt: DateTime.now(),
      );
      
      // Save user
      final storage = UserStorageService();
      await storage.saveUser(user);
      
      // Check if mounted before navigation
      if (mounted) {
        // Navigate to home/dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboard(user: user),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}