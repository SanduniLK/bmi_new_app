import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bmi_record.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============= USER PROFILE =============

  Future<AppUser?> getAppUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      print('❌ Error getting AppUser: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      return doc.data();
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // ============= BMI RECORDS =============

  Future<void> saveBMIRecord(BMIRecord record) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bmi_records')
          .add(record.toJson());
      print('✅ BMI record saved');
    } catch (e) {
      print('❌ Error saving BMI record: $e');
      rethrow;
    }
  }

  Stream<List<BMIRecord>> getBMIHistory() {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bmi_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BMIRecord.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<BMIRecord?> getLatestBMIRecord() async {
    final User? user = _auth.currentUser;
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
      print('❌ Error getting latest BMI record: $e');
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
      
      return snapshot.docs.map((doc) {
        return FoodItem.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error getting food recommendations: $e');
      return [];
    }
  }
}