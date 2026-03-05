import 'package:flutter/material.dart';

class FoodPreferencesScreen extends StatefulWidget {
  final List<String> selectedPreferences;
  
  const FoodPreferencesScreen({
    super.key,
    required this.selectedPreferences,
  });

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  late List<String> _selected;
  
  final Map<String, Map<String, dynamic>> foodCategories = {
    'Vegetarian': {
      'icon': Icons.eco,
      'color': Colors.green,
      'description': 'No meat, fish, or eggs',
    },
    'Vegan': {
      'icon': Icons.spa,
      'color': Colors.lightGreen,
      'description': 'No animal products',
    },
    'Non-Vegetarian': {
      'icon': Icons.restaurant,
      'color': Colors.red,
      'description': 'Includes meat and fish',
    },
    'Eggetarian': {
      'icon': Icons.egg,
      'color': Colors.amber,
      'description': 'Includes eggs, no meat',
    },
    'Keto': {
      'icon': Icons.fastfood,
      'color': Colors.purple,
      'description': 'High fat, low carb',
    },
    'Low Carb': {
      'icon': Icons.energy_savings_leaf,
      'color': Colors.teal,
      'description': 'Reduced carbohydrates',
    },
    'High Protein': {
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'description': 'Protein-rich foods',
    },
    'Mediterranean': {
      'icon': Icons.oil_barrel,
      'color': Colors.blue,
      'description': 'Olive oil, fish, vegetables',
    },
    'Paleo': {
      'icon': Icons.forest,
      'color': Colors.brown,
      'description': 'Whole foods, no processed items',
    },
    'Gluten-Free': {
      'icon': Icons.grass,
      'color': Colors.cyan,
      'description': 'No wheat, barley, rye',
    },
    'Dairy-Free': {
      'icon': Icons.no_drinks,
      'color': Colors.indigo,
      'description': 'No milk products',
    },
  };

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedPreferences);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Preferences'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selected);
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select your dietary preferences',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foodCategories.length,
              itemBuilder: (context, index) {
                String category = foodCategories.keys.elementAt(index);
                var data = foodCategories[category]!;
                bool isSelected = _selected.contains(category);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected!) {
                          _selected.add(category);
                        } else {
                          _selected.remove(category);
                        }
                      });
                    },
                    title: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(data['description']),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: data['color'].withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data['icon'],
                        color: data['color'],
                      ),
                    ),
                    activeColor: Colors.deepPurple,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}