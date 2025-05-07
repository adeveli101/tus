import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          _buildSettingItem(
            title: 'Tema',
            subtitle: 'Sistem',
            icon: Icons.palette,
            onTap: () {
              // TODO: Implement theme settings
            },
          ),
          _buildSettingItem(
            title: 'Bildirimler',
            subtitle: 'Açık',
            icon: Icons.notifications,
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          _buildSettingItem(
            title: 'Dil',
            subtitle: 'Türkçe',
            icon: Icons.language,
            onTap: () {
              // TODO: Implement language settings
            },
          ),
          _buildSettingItem(
            title: 'Hakkında',
            icon: Icons.info,
            onTap: () {
              // TODO: Implement about page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 