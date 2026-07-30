import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';
import '../../models/purchase_model.dart';

// ---- আপনার PhonePe নম্বর এখানে বসানো আছে ----
const String kPhonePeNumber = '7439988344';

class CheckoutScreen extends StatefulWidget {
  final String courseId;
  const CheckoutScreen({super.key, required this.courseId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firestore = FirestoreService();
  final _couponCtrl = TextEditingController();
  final _txnIdCtrl = TextEditingController();
  CourseModel? _course;
  final double _discount = 0;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final course = await _firestore.getCourse(widget.courseId);
    setState(() => _course = course);
  }

  Future<void> _applyCoupon() async {
    if (_couponCtrl.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid coupon — connect this to your coupons collection.')),
    );
  }

  Future<void> _submitPayment() async {
    if (_course == null) return;
    final txnId = _txnIdCtrl.text.trim();
    if (txnId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ID লিখুন')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid;
    if (uid == null) return;

    setState(() => _submitting = true);

    final amount = _course!.effectivePrice - _discount;
    final purchase = PurchaseModel(
      id: const Uuid().v4(),
      studentUid: uid,
      courseId: _course!.id,
      courseTitle: _course!.title,
      amount: amount < 0 ? 0 : amount,
      phonepeTransactionId: txnId,
      status: PaymentStatus.pending,
      couponCode: _couponCtrl.text.trim().isEmpty ? null : _couponCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    await _firestore.recordPurchase(purchase);

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    _txnIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_course == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Submitted')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 64, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                'আপনার পেমেন্ট রিভিউ করা হচ্ছে',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'অ্যাডমিন যাচাই করে কোর্স অ্যাক্সেস দিয়ে দেবেন, সাধারণত কিছু সময়ের মধ্যেই। ধন্যবাদ!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('হোমে ফিরে যান'),
              ),
            ],
          ),
        ),
      );
    }

    final amount = _course!.effectivePrice - _discount;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
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
            _row('Course Price', '৳${_course!.price.toStringAsFixed(0)}'),
            if (_course!.discountPrice > 0) _row('Discount', '- ৳${(_course!.price - _course!.discountPrice).toStringAsFixed(0)}'),
            const Divider(height: 32),
            _row('Total Payable', '৳${amount.toStringAsFixed(0)}', bold: true),
            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phone_android, size: 20),
                      SizedBox(width: 8),
                      Text('PhonePe দিয়ে পেমেন্ট করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('এই নম্বরে ৳${amount.toStringAsFixed(0)} পাঠান:', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  SelectableText(
                    kPhonePeNumber,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'পেমেন্ট করার পর, PhonePe app-এ পাওয়া Transaction ID/UTR নম্বরটি নিচে লিখে সাবমিট করুন। অ্যাডমিন যাচাই করার পর আপনার কোর্স আনলক হয়ে যাবে।',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _txnIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Transaction ID / UTR নম্বর',
                prefixIcon: Icon(Icons.receipt_long_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitPayment,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('পেমেন্ট জানিয়ে দিন'),
              ),
            ),
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
