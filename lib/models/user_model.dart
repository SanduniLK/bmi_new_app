import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final int? age;
  final double? weight;
  final int? height;
  final String? gender;
  final List<String> foodPreferences;  // Changed from dietTypes to match Firestore
  final String? dietGoal;               // Changed from healthGoal to match Firestore
  final String? activityLevel;
  final List<String> allergies;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.foodPreferences = const [],    // Match Firestore field name
    this.dietGoal,                       // Match Firestore field name
    this.activityLevel,
    this.allergies = const [],
    this.photoURL,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'foodPreferences': foodPreferences,  // Match Firestore
      'dietGoal': dietGoal,                 // Match Firestore
      'activityLevel': activityLevel,
      'allergies': allergies,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json, String uid) {
    return AppUser(
      uid: uid,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      age: json['age'],
      weight: (json['weight'] as num?)?.toDouble(),
      height: json['height'],
      gender: json['gender'],
      foodPreferences: List<String>.from(json['foodPreferences'] ?? []), // Match Firestore
      dietGoal: json['dietGoal'],                                         // Match Firestore
      activityLevel: json['activityLevel'],
      allergies: List<String>.from(json['allergies'] ?? []),
      photoURL: json['photoURL'],
      createdAt: json['createdAt'] != null 
          ? _parseDate(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? _parseDate(json['updatedAt'])
          : null,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    }
    return DateTime.now();
  }

  double? calculateBMI() {
    if (weight == null || height == null) return null;
    double heightInM = height! / 100;
    return weight! / (heightInM * heightInM);
  }

  String? getBMICategory() {
    final double? bmi = calculateBMI();
    if (bmi == null) return null;
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  // Helper method to get diet types (for backward compatibility)
  List<String> get dietTypes => foodPreferences;
  
  // Helper method to get health goal (for backward compatibility)
  String? get healthGoal => dietGoal;
}