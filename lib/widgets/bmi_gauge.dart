import 'package:flutter/material.dart';

class BMIGauge extends StatelessWidget {
  final double bmi;
  
  const BMIGauge({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF42A5F5), // Underweight - Blue
                Color(0xFF66BB6A), // Normal - Green
                Color(0xFFFFA726), // Overweight - Orange
                Color(0xFFEF5350), // Obese - Red
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBMILabel('18.5', 'Underweight'),
            _buildBMILabel('25', 'Normal'),
            _buildBMILabel('30', 'Overweight'),
            _buildBMILabel('40+', 'Obese'),
          ],
        ),
        const SizedBox(height: 16),
        _buildIndicator(context), // Pass context as parameter
      ],
    );
  }

  Widget _buildBMILabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(BuildContext context) { // Add BuildContext parameter
    double position = _calculatePosition();
    
    return Stack(
      children: [
        Container(
          height: 2,
          color: Colors.grey.shade300,
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.8 * position, // Now 'context' is correct
          child: Column(
            children: [
              Icon(
                Icons.arrow_drop_up,
                color: _getBMIColor(),
                size: 24,
              ),
              Text(
                'You',
                style: TextStyle(
                  fontSize: 10,
                  color: _getBMIColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculatePosition() {
    if (bmi < 18.5) {
      return (bmi / 18.5) * 0.25;
    } else if (bmi < 25) {
      return 0.25 + ((bmi - 18.5) / (25 - 18.5)) * 0.25;
    } else if (bmi < 30) {
      return 0.5 + ((bmi - 25) / (30 - 25)) * 0.25;
    } else {
      return 0.75 + ((bmi - 30) / 10) * 0.25;
    }
  }

  Color _getBMIColor() {
    if (bmi < 18.5) return const Color(0xFF42A5F5);
    if (bmi < 25) return const Color(0xFF66BB6A);
    if (bmi < 30) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }
}