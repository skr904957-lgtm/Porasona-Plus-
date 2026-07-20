import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/connectivity_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final connectivity = context.watch<ConnectivityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between Light and Dark theme'),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggle(),
          ),
          ListTile(
            leading: Icon(connectivity.isOnline ? Icons.wifi : Icons.wifi_off, color: connectivity.isOnline ? Colors.green : Colors.orange),
            title: const Text('Connection Status'),
            subtitle: Text(connectivity.isOnline ? 'Online' : 'Offline — downloaded content still available'),
          ),
          const Divider(),
          const ListTile(leading: Icon(Icons.info_outline), title: Text('App Version'), subtitle: Text('1.0.0')),
          const ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('Privacy Policy')),
          const ListTile(leading: Icon(Icons.description_outlined), title: Text('Terms of Service')),
        ],
      ),
    );
  }
}
