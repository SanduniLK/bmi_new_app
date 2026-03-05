import 'package:flutter/material.dart';
import 'result.dart';

class Calculate extends StatefulWidget {
  const Calculate({super.key});

  @override
  State<Calculate> createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {
  bool? isMale;
  int selectedWeight = 60;
  int selectedHeight = 170;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea( // Add SafeArea to avoid notches
        child: SingleChildScrollView( // Make the entire body scrollable
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Change to min
            children: [
              // Gender Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded( // Wrap with Expanded for flexible sizing
                    child: buildGenderButton(
                      icon: Icons.boy,
                      label: "Male",
                      selected: isMale == true,
                      color: Colors.blue,
                      onTap: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded( // Wrap with Expanded for flexible sizing
                    child: buildGenderButton(
                      icon: Icons.girl,
                      label: "Female",
                      selected: isMale == false,
                      color: Colors.pink,
                      onTap: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Weight and Height Pickers
              Container( // Wrap in Container with fixed height
                height: 200, // Fixed height to prevent overflow
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Weight
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Weight (kg)", 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded( // Use Expanded for the wheel
                            child: Container(
                              height: 120,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 40,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedWeight = index + 30;
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 121,
                                  builder: (context, index) {
                                    return Center(
                                      child: Text("${index + 30} kg"),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Selected: $selectedWeight kg",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Height
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Height (cm)", 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded( // Use Expanded for the wheel
                            child: Container(
                              height: 120,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 40,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    selectedHeight = index + 100;
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 121,
                                  builder: (context, index) {
                                    return Center(
                                      child: Text("${index + 100} cm"),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Selected: $selectedHeight cm",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // See Results Button
              ElevatedButton(
                onPressed: isMale == null ? null : () {
                  double heightM = selectedHeight / 100;
                  double bmi = selectedWeight / (heightM * heightM);

                  String category;
                  if (bmi < 18.5) {
                    category = "Underweight";
                  } else if (bmi < 25) {
                    category = "Normal weight";
                  } else if (bmi < 30) {
                    category = "Overweight";
                  } else {
                    category = "Obese";
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BMIResultPage(
                        bmi: bmi,
                        category: category,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMale == null ? Colors.grey : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "See Your Results",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gender Button Widget
  Widget buildGenderButton({
    required IconData icon,
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140, // Fixed height
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.8) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: selected ? Colors.white : color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}