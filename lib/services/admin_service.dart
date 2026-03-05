import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  // List of admin emails (hardcoded for security)
  static const List<String> _adminEmails = [
    'ab@gmail.com',
    'admin@bmi-app.com',
    // Add more admin emails here
  ];

  // Check if current user is admin
  static bool isAdmin(User? user) {
    if (user == null) return false;
    return _adminEmails.contains(user.email?.toLowerCase());
  }

  // Get admin status stream
  static Stream<bool> adminStatusStream() {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      return isAdmin(user);
    });
  }
}