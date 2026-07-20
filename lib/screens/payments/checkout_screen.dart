import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../app/app_config.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/payment_service.dart';
import '../../models/course_model.dart';
import '../../models/purchase_model.dart';

class CheckoutScreen extends StatefulWidget {
  final String courseId;
  const CheckoutScreen({super.key, required this.courseId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firestore = FirestoreService();
  final _paymentService = PaymentService();
  final _couponCtrl = TextEditingController();
  CourseModel? _course;
  double _discount = 0;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _load();
    _paymentService.init(
      onSuccess: _onSuccess,
      onError: _onError,
      onExternalWallet: (_) {},
    );
  }

  Future<void> _load() async {
    final course = await _firestore.getCourse(widget.courseId);
    setState(() => _course = course);
  }

  Future<void> _applyCoupon() async {
    // Coupons are validated against the `coupons` collection managed by the admin.
    // Wire this up to a real lookup once you've created coupon documents there.
    if (_couponCtrl.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid coupon — connect this to your coupons collection.')),
    );
  }

  void _startPayment() {
    if (_course == null) return;
    final auth = context.read<AuthProvider>();
    final amount = _course!.effectivePrice - _discount;
    final orderId = const Uuid().v4(); // Replace with a real order_id from your backend's Razorpay Orders API call.

    setState(() => _processing = true);
    _paymentService.openCheckout(
      razorpayKeyId: AppConfig.razorpayKeyId,
      orderId: orderId,
      amountInRupees: amount < 0 ? 0 : amount,
      courseTitle: _course!.title,
      studentName: auth.student?.name ?? '',
      studentEmail: auth.student?.email ?? auth.firebaseUser?.email ?? '',
      studentPhone: auth.student?.phone,
    );
  }

  Future<void> _onSuccess(PaymentSuccessResponse response) async {
    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid;
    if (uid != null && _course != null) {
      final purchase = PurchaseModel(
        id: const Uuid().v4(),
        studentUid: uid,
        courseId: _course!.id,
        courseTitle: _course!.title,
        amount: _course!.effectivePrice - _discount,
        razorpayPaymentId: response.paymentId,
        razorpayOrderId: response.orderId,
        status: PaymentStatus.success,
        couponCode: _couponCtrl.text.trim().isEmpty ? null : _couponCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await _firestore.recordPurchase(purchase);
      final updatedIds = [...(auth.student?.purchasedCourseIds ?? []), _course!.id];
      await _firestore.updateStudent(uid, {'purchasedCourseIds': updatedIds});
      await auth.refreshStudent();
    }
    if (!mounted) return;
    setState(() => _processing = false);
    Navigator.pushReplacementNamed(context, AppRoutes.paymentSuccess);
  }

  void _onError(PaymentFailureResponse response) {
    setState(() => _processing = false);
    Navigator.pushReplacementNamed(context, AppRoutes.paymentFailed);
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_course == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final amount = _course!.effectivePrice - _discount;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_course!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_course!.subject, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCtrl,
                    decoration: const InputDecoration(labelText: 'Coupon Code', prefixIcon: Icon(Icons.local_offer_outlined)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _applyCoupon, child: const Text('Apply')),
              ],
            ),
            const SizedBox(height: 24),
            _row('Course Price', '₹${_course!.price.toStringAsFixed(0)}'),
            if (_course!.discountPrice > 0) _row('Discount', '- ₹${(_course!.price - _course!.discountPrice).toStringAsFixed(0)}'),
            if (_discount > 0) _row('Coupon Discount', '- ₹${_discount.toStringAsFixed(0)}'),
            const Divider(height: 32),
            _row('Total Payable', '₹${amount.toStringAsFixed(0)}', bold: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _startPayment,
                child: _processing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Proceed to Pay'),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Secured by Razorpay', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14, color: bold ? AppColors.primary : Colors.black87);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: style), Text(value, style: style)]),
    );
  }
}
