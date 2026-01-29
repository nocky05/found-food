import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Compte'),
          _buildSettingItem(Icons.person_outline, 'Informations personnelles'),
          _buildSettingItem(Icons.lock_outline, 'Mot de passe et sécurité'),
          _buildSettingItem(Icons.notifications_none, 'Notifications'),
          
          _buildSection('Préférences'),
          _buildSettingItem(Icons.language, 'Langue', trailing: 'Français'),
          _buildSettingItem(Icons.dark_mode_outlined, 'Mode sombre', isSwitch: true),
          
          _buildSection('Assistance'),
          _buildSettingItem(Icons.help_outline, 'Aide et support'),
          _buildSettingItem(Icons.info_outline, 'À propos'),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
            child: ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (context.mounted) {
                   Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.errorColor,
                elevation: 0,
                side: const BorderSide(color: AppColors.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTypography.h4.copyWith(
          color: AppColors.primaryOrange,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? trailing, bool isSwitch = false}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary, size: 22),
        title: Text(title, style: AppTypography.bodyMedium),
        trailing: isSwitch 
          ? Switch(value: false, onChanged: (v) {}, activeColor: AppColors.primaryOrange)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) 
                  Text(trailing, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
              ],
            ),
        onTap: () {},
      ),
    );
  }
}
