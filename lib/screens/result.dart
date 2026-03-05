import 'package:flutter/material.dart';

class BMIResultPage extends StatelessWidget {
  final double bmi;
  final String category;

  const BMIResultPage({
    super.key,
    required this.bmi,
    required this.category,
  });

  String getAdvice(String category) {
    switch (category) {
      case 'Underweight':
        return 'You are under the normal body weight. Try to eat more.';
      case 'Normal weight':
        return 'Great! You have a normal body weight. Keep it up!';
      case 'Overweight':
        return 'You are slightly over the normal body weight. Exercise more.';
      default:
        return 'You are obese. Consider consulting a doctor or dietitian.';
    }
  }

  Color getColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.orangeAccent;
      case 'Normal weight':
        return Colors.green;
      case 'Overweight':
        return Colors.deepOrange;
      default:
        return Colors.redAccent;
    }
  }

  IconData getIcon(String category) {
    switch (category) {
      case 'Underweight':
        return Icons.sentiment_dissatisfied;
      case 'Normal weight':
        return Icons.sentiment_satisfied_alt;
      case 'Overweight':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(category);

    return Scaffold(
      backgroundColor: color.withOpacity(0.1),
      appBar: AppBar(
        title: const Text("BMI Result"),
        backgroundColor: color,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(getIcon(category), size: 60, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "Your BMI",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  Text(
                    bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    getAdvice(category),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Recalculate"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
