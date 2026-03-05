import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bmr_model.dart';

class BMRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get today's food entries
  Stream<List<FoodEntry>> getTodayFoodEntries() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_nutrition')
        .doc(dateStr)
        .collection('food_entries')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return FoodEntry.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Add food entry
  Future<void> addFoodEntry(FoodEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_nutrition')
        .doc(dateStr)
        .collection('food_entries')
        .add(entry.toJson());
  }

  // Delete food entry
  Future<void> deleteFoodEntry(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_nutrition')
        .doc(dateStr)
        .collection('food_entries')
        .doc(entryId)
        .delete();
  }
}