import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _supportEmailCtrl = TextEditingController();
  final _supportPhoneCtrl = TextEditingController();
  bool _maintenanceMode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('app_settings').doc('config').get();
    final data = doc.data() ?? {};
    _supportEmailCtrl.text = data['supportEmail'] ?? '';
    _supportPhoneCtrl.text = data['supportPhone'] ?? '';
    _maintenanceMode = data['maintenanceMode'] ?? false;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance.collection('app_settings').doc('config').set({
      'supportEmail': _supportEmailCtrl.text.trim(),
      'supportPhone': _supportPhoneCtrl.text.trim(),
      'maintenanceMode': _maintenanceMode,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _supportEmailCtrl, decoration: const InputDecoration(labelText: 'Support Email')),
            const SizedBox(height: 14),
            TextField(controller: _supportPhoneCtrl, decoration: const InputDecoration(labelText: 'Support Phone')),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Temporarily block student access for updates'),
              value: _maintenanceMode,
              onChanged: (v) => setState(() => _maintenanceMode = v),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Save Settings'))),
          ],
        ),
      ),
    );
  }
}
