import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MacroChart extends StatelessWidget {
  final Map<String, dynamic> calorieRange;

  const MacroChart({
    super.key,
    required this.calorieRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutrient Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMacroPie(
                  'Protein',
                  calorieRange['protein']?.toDouble() ?? 0,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMacroPie(
                  'Carbs',
                  calorieRange['carbs']?.toDouble() ?? 0,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildMacroPie(
                  'Fats',
                  calorieRange['fats']?.toDouble() ?? 0,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPie(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: value / 300, // Approximate max
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${value.toInt()}g',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}