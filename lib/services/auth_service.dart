import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // The ONLY admin user ID that can access admin pages
  static const String _adminUserId = 'ID3WGIInt2V2pakb5RoDFYXJgcD2';
  
  User? _user;
  User? get user => _user;

  // Check if current user is admin (by user ID)
  bool get isAdmin {
    return _user?.uid == _adminUserId;
  }

  // Get current user's role
  String get userRole {
    return isAdmin ? 'admin' : 'user';
  }

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    int? age,
    double? weight,
    int? height,
    String? gender,
    List<String>? foodPreferences,
    String? dietGoal,
    String? activityLevel,
    List<String>? allergies,
    double? initialBMI,
  }) async {
    try {
      debugPrint('📝 Attempting to register: $email');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);
        await user.reload();
        debugPrint('✅ User created: ${user.uid}');
        
        // Check if this is the admin user ID
        bool isAdminUser = user.uid == _adminUserId;
        if (isAdminUser) {
          debugPrint('👑 Admin user registered!');
        }
        
        // Create user profile in Firestore with role information
        final appUser = AppUser(
          uid: user.uid,
          email: email,
          name: name,
          age: age,
          weight: weight,
          height: height,
          gender: gender,
          foodPreferences: foodPreferences ?? [],
          dietGoal: dietGoal,
          activityLevel: activityLevel,
          allergies: allergies ?? [],
          photoURL: null,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(appUser.toJson());
        debugPrint('✅ User profile saved to Firestore');
        
        // Save initial BMI if provided
        if (initialBMI != null && weight != null && height != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('bmi_records')
              .add({
            'bmi': initialBMI,
            'weight': weight,
            'height': height,
            'category': _getBMICategory(initialBMI),
            'date': DateTime.now().toIso8601String(),
          });
          debugPrint('✅ Initial BMI record saved');
        }
      }
      
      return user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Check if this is the admin user
        if (user.uid == _adminUserId) {
          debugPrint('👑 Admin user logged in: ${user.uid}');
        } else {
          debugPrint('👤 Regular user logged in: ${user.uid}');
        }
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Error: ${e.message}';
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }
}