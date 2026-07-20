import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles all Firebase Authentication operations.
/// No demo/mock users — every call talks to real Firebase Auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    String classGrade = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    await _firestore.collection('students').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'classGrade': classGrade,
      'joinedAt': DateTime.now().millisecondsSinceEpoch,
      'studyStreak': 0,
      'totalPoints': 0,
      'bookmarkedCourseIds': [],
      'purchasedCourseIds': [],
      'isPremium': false,
    });

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  /// Checks the `admins` collection to see if the logged-in user has admin rights.
  Future<bool> isCurrentUserAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore.collection('admins').doc(uid).get();
    return doc.exists;
  }
}
