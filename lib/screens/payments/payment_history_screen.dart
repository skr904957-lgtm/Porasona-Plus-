import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/purchase_model.dart';
import '../../widgets/empty_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().firebaseUser?.uid;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: uid == null
          ? const EmptyState(title: 'Please log in')
          : StreamBuilder<List<PurchaseModel>>(
              stream: firestore.purchasesForStudent(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final purchases = snapshot.data!;
                if (purchases.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    subtitle: 'Your payment history will appear here after your first purchase.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: purchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = purchases[i];
                    final statusColor = p.status == PaymentStatus.success
                        ? AppColors.success
                        : p.status == PaymentStatus.failed
                            ? AppColors.error
                            : AppColors.warning;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(p.courseTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Text('₹${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Order ID: ${p.razorpayOrderId ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Transaction ID: ${p.razorpayPaymentId ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(DateFormat('MMM d, y • h:mm a').format(p.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(p.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  backgroundColor: statusColor,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    // Hook this up to your PDF skill / a Cloud Function that renders
                                    // a receipt from this purchase record.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Connect this to your receipt-generation backend.')),
                                    );
                                  },
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text('Receipt'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
