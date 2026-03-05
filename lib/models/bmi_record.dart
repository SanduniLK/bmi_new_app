import 'package:cloud_firestore/cloud_firestore.dart';

class BMIRecord {
  final String? id;
  final double bmi;
  final double weight;
  final int height;
  final String category;
  final DateTime date;
  final Map<String, dynamic>? additionalData;

  BMIRecord({
    this.id,
    required this.bmi,
    required this.weight,
    required this.height,
    required this.category,
    required this.date,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'bmi': bmi,
      'weight': weight,
      'height': height,
      'category': category,
      'date': Timestamp.fromDate(date),
      'additionalData': additionalData,
    };
  }

  factory BMIRecord.fromJson(Map<String, dynamic> json, [String? id]) {
    return BMIRecord(
      id: id,
      bmi: (json['bmi'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      height: json['height'] as int,
      category: json['category'] as String,
      date: (json['date'] as Timestamp).toDate(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }
}