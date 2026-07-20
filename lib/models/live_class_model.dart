class LiveClassModel {
  final String id;
  final String title;
  final String subject;
  final String teacherName;
  final DateTime scheduledAt;
  final String meetingUrl;
  final int durationMinutes;
  final bool isLive;

  LiveClassModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.scheduledAt,
    required this.meetingUrl,
    this.durationMinutes = 60,
    this.isLive = false,
  });

  factory LiveClassModel.fromMap(String id, Map<String, dynamic> map) {
    return LiveClassModel(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      teacherName: map['teacherName'] ?? '',
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledAt'])
          : DateTime.now(),
      meetingUrl: map['meetingUrl'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 60,
      isLive: map['isLive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subject': subject,
        'teacherName': teacherName,
        'scheduledAt': scheduledAt.millisecondsSinceEpoch,
        'meetingUrl': meetingUrl,
        'durationMinutes': durationMinutes,
        'isLive': isLive,
      };
}
