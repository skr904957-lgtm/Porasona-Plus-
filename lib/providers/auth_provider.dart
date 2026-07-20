import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  StudentModel? _student;
  bool _isAdmin = false;
  bool _loading = true;

  User? get firebaseUser => _firebaseUser;
  StudentModel? get student => _student;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _loading;
  bool get isLoggedIn => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _student = await _firestoreService.getStudent(user.uid);
      _isAdmin = await _authService.isCurrentUserAdmin();
    } else {
      _student = null;
      _isAdmin = false;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshStudent() async {
    if (_firebaseUser != null) {
      _student = await _firestoreService.getStudent(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) =>
      _authService.login(email: email, password: password);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String classGrade = '',
  }) =>
      _authService.signUp(name: name, email: email, password: password, classGrade: classGrade);

  Future<void> forgotPassword(String email) => _authService.sendPasswordResetEmail(email);

  Future<void> logout() => _authService.signOut();
}
