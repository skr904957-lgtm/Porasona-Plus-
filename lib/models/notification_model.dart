class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    this.read = false,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      sentAt: map['sentAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sentAt'])
          : DateTime.now(),
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'sentAt': sentAt.millisecondsSinceEpoch,
        'read': read,
      };
}
