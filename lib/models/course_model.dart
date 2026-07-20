class CourseModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String category;
  final String teacherName;
  final String thumbnailUrl;
  final bool isPremium;
  final double price;
  final double discountPrice;
  final List<String> videoIds;
  final List<String> pdfIds;
  final double rating;
  final int enrolledCount;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.category,
    required this.teacherName,
    required this.thumbnailUrl,
    this.isPremium = false,
    this.price = 0,
    this.discountPrice = 0,
    this.videoIds = const [],
    this.pdfIds = const [],
    this.rating = 0,
    this.enrolledCount = 0,
    required this.createdAt,
  });

  double get effectivePrice => discountPrice > 0 ? discountPrice : price;

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      category: map['category'] ?? '',
      teacherName: map['teacherName'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      isPremium: map['isPremium'] ?? false,
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0).toDouble(),
      videoIds: List<String>.from(map['videoIds'] ?? []),
      pdfIds: List<String>.from(map['pdfIds'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      enrolledCount: map['enrolledCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'category': category,
      'teacherName': teacherName,
      'thumbnailUrl': thumbnailUrl,
      'isPremium': isPremium,
      'price': price,
      'discountPrice': discountPrice,
      'videoIds': videoIds,
      'pdfIds': pdfIds,
      'rating': rating,
      'enrolledCount': enrolledCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
