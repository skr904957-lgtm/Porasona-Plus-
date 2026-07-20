enum TestType { daily, weekly, mock, previousYear }

class QuestionModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final bool isDescriptive;
  final String? answerKeyUrl;

  QuestionModel({
    required this.id,
    required this.questionText,
    this.options = const [],
    this.correctOptionIndex = -1,
    this.isDescriptive = false,
    this.answerKeyUrl,
  });

  factory QuestionModel.fromMap(String id, Map<String, dynamic> map) {
    return QuestionModel(
      id: id,
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? -1,
      isDescriptive: map['isDescriptive'] ?? false,
      answerKeyUrl: map['answerKeyUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'questionText': questionText,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'isDescriptive': isDescriptive,
        'answerKeyUrl': answerKeyUrl,
      };
}

class TestModel {
  final String id;
  final String title;
  final TestType type;
  final String subject;
  final int durationMinutes;
  final int totalMarks;
  final DateTime scheduledAt;
  final List<String> questionIds;

  TestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.subject,
    required this.durationMinutes,
    required this.totalMarks,
    required this.scheduledAt,
    this.questionIds = const [],
  });

  factory TestModel.fromMap(String id, Map<String, dynamic> map) {
    return TestModel(
      id: id,
      title: map['title'] ?? '',
      type: TestType.values.firstWhere(
        (t) => t.name == (map['type'] ?? 'daily'),
        orElse: () => TestType.daily,
      ),
      subject: map['subject'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 30,
      totalMarks: map['totalMarks'] ?? 100,
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledAt'])
          : DateTime.now(),
      questionIds: List<String>.from(map['questionIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type.name,
        'subject': subject,
        'durationMinutes': durationMinutes,
        'totalMarks': totalMarks,
        'scheduledAt': scheduledAt.millisecondsSinceEpoch,
        'questionIds': questionIds,
      };
}
