class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String classGrade;
  final DateTime joinedAt;
  final int studyStreak;
  final int totalPoints;
  final List<String> bookmarkedCourseIds;
  final List<String> purchasedCourseIds;
  final bool isPremium;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.classGrade = '',
    required this.joinedAt,
    this.studyStreak = 0,
    this.totalPoints = 0,
    this.bookmarkedCourseIds = const [],
    this.purchasedCourseIds = const [],
    this.isPremium = false,
  });

  factory StudentModel.fromMap(String uid, Map<String, dynamic> map) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      classGrade: map['classGrade'] ?? '',
      joinedAt: map['joinedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['joinedAt'])
          : DateTime.now(),
      studyStreak: map['studyStreak'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      bookmarkedCourseIds: List<String>.from(map['bookmarkedCourseIds'] ?? []),
      purchasedCourseIds: List<String>.from(map['purchasedCourseIds'] ?? []),
      isPremium: map['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'classGrade': classGrade,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'studyStreak': studyStreak,
      'totalPoints': totalPoints,
      'bookmarkedCourseIds': bookmarkedCourseIds,
      'purchasedCourseIds': purchasedCourseIds,
      'isPremium': isPremium,
    };
  }
}
