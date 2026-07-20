import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/course_model.dart';
import '../models/test_model.dart';
import '../models/live_class_model.dart';
import '../models/notification_model.dart';
import '../models/purchase_model.dart';

/// Single source of truth for reading/writing app data in Cloud Firestore.
/// Every method streams or fetches real documents — nothing here is mocked.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- Students ----------
  Stream<StudentModel> studentStream(String uid) {
    return _db.collection('students').doc(uid).snapshots().map(
        (doc) => StudentModel.fromMap(doc.id, doc.data() ?? {}));
  }

  Future<StudentModel?> getStudent(String uid) async {
    final doc = await _db.collection('students').doc(uid).get();
    if (!doc.exists) return null;
    return StudentModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateStudent(String uid, Map<String, dynamic> data) {
    return _db.collection('students').doc(uid).update(data);
  }

  Stream<List<StudentModel>> allStudents() {
    return _db.collection('students').orderBy('joinedAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => StudentModel.fromMap(d.id, d.data())).toList());
  }

  // ---------- Courses ----------
  Stream<List<CourseModel>> courses({String? category, String? subject}) {
    Query<Map<String, dynamic>> q = _db.collection('courses');
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    if (subject != null && subject.isNotEmpty) {
      q = q.where('subject', isEqualTo: subject);
    }
    return q.orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => CourseModel.fromMap(d.id, d.data())).toList());
  }

  Future<CourseModel?> getCourse(String id) async {
    final doc = await _db.collection('courses').doc(id).get();
    if (!doc.exists) return null;
    return CourseModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> addCourse(CourseModel course) {
    return _db.collection('courses').doc(course.id).set(course.toMap());
  }

  Future<void> deleteCourse(String id) {
    return _db.collection('courses').doc(id).delete();
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    final snap = await _db.collection('courses').get();
    final lower = query.toLowerCase();
    return snap.docs
        .map((d) => CourseModel.fromMap(d.id, d.data()))
        .where((c) =>
            c.title.toLowerCase().contains(lower) ||
            c.subject.toLowerCase().contains(lower) ||
            c.category.toLowerCase().contains(lower))
        .toList();
  }

  // ---------- Live Classes ----------
  Stream<List<LiveClassModel>> liveClasses() {
    return _db
        .collection('live_classes')
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => LiveClassModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> addLiveClass(LiveClassModel liveClass) {
    return _db.collection('live_classes').doc(liveClass.id).set(liveClass.toMap());
  }

  // ---------- Tests ----------
  Stream<List<TestModel>> testsByType(TestType type) {
    return _db
        .collection('tests')
        .where('type', isEqualTo: type.name)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TestModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> addTest(TestModel test) {
    return _db.collection('tests').doc(test.id).set(test.toMap());
  }

  Future<void> submitTestResult({
    required String studentUid,
    required String testId,
    required int score,
    required int totalMarks,
  }) {
    return _db.collection('test_results').add({
      'studentUid': studentUid,
      'testId': testId,
      'score': score,
      'totalMarks': totalMarks,
      'submittedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ---------- Leaderboard ----------
  Stream<List<StudentModel>> leaderboard({int limit = 50}) {
    return _db
        .collection('students')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => StudentModel.fromMap(d.id, d.data())).toList());
  }

  // ---------- Notifications ----------
  Stream<List<NotificationModel>> notifications(String uid) {
    return _db
        .collection('students')
        .doc(uid)
        .collection('notifications')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NotificationModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> broadcastNotification({required String title, required String body}) async {
    final students = await _db.collection('students').get();
    final batch = _db.batch();
    for (final doc in students.docs) {
      final ref = doc.reference.collection('notifications').doc();
      batch.set(ref, {
        'title': title,
        'body': body,
        'sentAt': DateTime.now().millisecondsSinceEpoch,
        'read': false,
      });
    }
    await batch.commit();
  }

  // ---------- Purchases / Payments ----------
  Future<void> recordPurchase(PurchaseModel purchase) {
    return _db.collection('purchases').doc(purchase.id).set(purchase.toMap());
  }

  Stream<List<PurchaseModel>> purchasesForStudent(String uid) {
    return _db
        .collection('purchases')
        .where('studentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PurchaseModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<PurchaseModel>> allPurchases() {
    return _db
        .collection('purchases')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PurchaseModel.fromMap(d.id, d.data())).toList());
  }

  // ---------- Banners / Announcements / Categories ----------
  Stream<List<Map<String, dynamic>>> banners() {
    return _db.collection('banners').orderBy('order').snapshots().map(
        (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> announcements() {
    return _db.collection('announcements').orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> categories() {
    return _db.collection('categories').orderBy('order').snapshots().map(
        (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
