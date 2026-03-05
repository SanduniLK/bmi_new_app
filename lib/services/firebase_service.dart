import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/food_model.dart';
import '../models/bmi_record.dart';

class FirebaseService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============= AUTHENTICATION =============
  
  Future<auth.User?> signUpWithEmail({
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
      debugPrint('📝 Attempting to sign up with email: $email');
      
      final auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }
      
      debugPrint('✅ User created successfully: ${user.uid}');
      
      // Update display name
      await user.updateDisplayName(name);
      await user.reload();
      debugPrint('✅ Display name updated: $name');
      
      // Create user profile in Firestore with correct field names
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
      
      await createUserProfile(appUser);
      debugPrint('✅ User profile created in Firestore');
      
      // Save initial BMI if provided
      if (initialBMI != null && weight != null && height != null) {
        final bmiRecord = BMIRecord(
          bmi: initialBMI,
          weight: weight,
          height: height,
          category: _getBMICategory(initialBMI),
          date: DateTime.now(),
        );
        await saveBMIRecord(bmiRecord);
      }
      
      return user;
      
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Exception:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      
      final String errorMessage = _handleAuthException(e);
      throw Exception(errorMessage);
      
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during sign up:');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Registration failed: $e');
    }
  }

  Future<auth.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📝 Attempting to sign in with email: $email');
      
      final auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ Sign in successful: ${result.user?.uid}');
      return result.user;
      
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Exception:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      
      final String errorMessage = _handleSignInException(e);
      throw Exception(errorMessage);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('✅ User signed out');
  }

  auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  // ============= USER PROFILE =============

  Future<void> createUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());
      debugPrint('✅ User profile created in Firestore for: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (uid.isEmpty) {
      debugPrint('❌ Error: uid is empty');
      return null;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      return null;
    }
  }

  Future<AppUser?> getAppUser(String uid) async {
    if (uid.isEmpty) {
      debugPrint('❌ Error: uid is empty');
      return null;
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        return AppUser.fromJson(documentSnapshot.data()!, uid);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting AppUser: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    if (uid.isEmpty) {
      throw Exception('Cannot update profile: uid is empty');
    }

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update(data);
      debugPrint('✅ User profile updated for: $uid');
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // ============= BMI RECORDS =============

  Future<void> saveBMIRecord(BMIRecord record) async {
    final auth.User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bmi_records')
          .add(record.toJson());
      debugPrint('✅ BMI record saved for user: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Error saving BMI record: $e');
      rethrow;
    }
  }

  Stream<List<BMIRecord>> getBMIHistory() {
    final auth.User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bmi_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            return BMIRecord.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<BMIRecord?> getLatestBMIRecord() async {
    final auth.User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bmi_records')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return BMIRecord.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
    } catch (e) {
      debugPrint('❌ Error getting latest BMI record: $e');
    }
    return null;
  }

  // ============= FOOD RECOMMENDATIONS =============

  Future<List<FoodItem>> getFoodRecommendations(String bmiCategory) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('foods')
          .where('suitableForBMI', arrayContains: bmiCategory.toLowerCase())
          .get();
      
      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return FoodItem.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting food recommendations: $e');
      return [];
    }
  }

  // ============= HELPER METHODS =============

  String _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password sign up is not enabled. Please enable it in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Error: ${e.message ?? "Unknown error occurred"}';
    }
  }

  String _handleSignInException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Error: ${e.message ?? "Unknown error occurred"}';
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }
}