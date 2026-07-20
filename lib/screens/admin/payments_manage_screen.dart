import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/purchase_model.dart';
import '../../widgets/empty_state.dart';

class PaymentsManageScreen extends StatefulWidget {
  const PaymentsManageScreen({super.key});

  @override
  State<PaymentsManageScreen> createState() => _PaymentsManageScreenState();
}

class _PaymentsManageScreenState extends State<PaymentsManageScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showAddCouponDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final percentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Coupon Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Coupon Code')),
            TextField(controller: percentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount %')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (codeCtrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('coupons').doc(codeCtrl.text.trim().toUpperCase()).set({
                'discountPercent': int.tryParse(percentCtrl.text) ?? 0,
                'active': true,
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Revenue'),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Revenue'), Tab(text: 'Purchases'), Tab(text: 'Coupons')]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------- Revenue Dashboard ----------
          StreamBuilder<List<PurchaseModel>>(
            stream: firestore.allPurchases(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final purchases = snapshot.data!.where((p) => p.status == PaymentStatus.success).toList();
              final totalRevenue = purchases.fold<double>(0, (sum, p) => sum + p.amount);
              final now = DateTime.now();
              final thisMonth = purchases.where((p) => p.createdAt.month == now.month && p.createdAt.year == now.year);
              final monthRevenue = thisMonth.fold<double>(0, (sum, p) => sum + p.amount);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _RevenueCard(label: 'Total Revenue', value: '₹${totalRevenue.toStringAsFixed(0)}')),
                      const SizedBox(width: 12),
                      Expanded(child: _RevenueCard(label: 'This Month', value: '₹${monthRevenue.toStringAsFixed(0)}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _RevenueCard(label: 'Total Successful Transactions', value: '${purchases.length}', full: true),
                ],
              );
            },
          ),
          // ---------- All Purchases ----------
          StreamBuilder<List<PurchaseModel>>(
            stream: firestore.allPurchases(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final purchases = snapshot.data!;
              if (purchases.isEmpty) {
                return const EmptyState(icon: Icons.receipt_long_outlined, title: 'No purchases yet');
              }
              return ListView.separated(
                itemCount: purchases.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = purchases[i];
                  return ListTile(
                    title: Text(p.courseTitle),
                    subtitle: Text('${p.status.name.toUpperCase()} • ₹${p.amount.toStringAsFixed(0)} • ${DateFormat('MMM d').format(p.createdAt)}'),
                  );
                },
              );
            },
          ),
          // ---------- Coupons ----------
          Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const EmptyState(icon: Icons.local_offer_outlined, title: 'No coupons created yet', subtitle: 'Tap + to add one.');
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.local_offer_outlined, color: AppColors.primary),
                        title: Text(docs[i].id),
                        subtitle: Text('${data['discountPercent'] ?? 0}% off'),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => docs[i].reference.delete()),
                      );
                    },
                  );
                },
              ),
              Positioned(
                bottom: 16, right: 16,
                child: FloatingActionButton(onPressed: () => _showAddCouponDialog(context), child: const Icon(Icons.add)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String label;
  final String value;
  final bool full;
  const _RevenueCard({required this.label, required this.value, this.full = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: full ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
