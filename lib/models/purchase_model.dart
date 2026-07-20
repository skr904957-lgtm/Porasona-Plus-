enum PaymentStatus { pending, success, failed }

class PurchaseModel {
  final String id;
  final String studentUid;
  final String courseId;
  final String courseTitle;
  final double amount;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final PaymentStatus status;
  final String? couponCode;
  final DateTime createdAt;

  PurchaseModel({
    required this.id,
    required this.studentUid,
    required this.courseId,
    required this.courseTitle,
    required this.amount,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.status = PaymentStatus.pending,
    this.couponCode,
    required this.createdAt,
  });

  factory PurchaseModel.fromMap(String id, Map<String, dynamic> map) {
    return PurchaseModel(
      id: id,
      studentUid: map['studentUid'] ?? '',
      courseId: map['courseId'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      razorpayPaymentId: map['razorpayPaymentId'],
      razorpayOrderId: map['razorpayOrderId'],
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      couponCode: map['couponCode'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'studentUid': studentUid,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'amount': amount,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'status': status.name,
        'couponCode': couponCode,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
