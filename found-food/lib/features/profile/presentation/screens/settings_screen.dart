import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:provider/provider.dart';
import 'package:found_food/features/auth/presentation/providers/auth_provider.dart';
import 'package:found_food/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:found_food/core/theme/theme_provider.dart';
import 'package:found_food/features/profile/presentation/screens/help_support_screen.dart';
import 'package:found_food/features/profile/presentation/screens/about_screen.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final profile = profileProvider.userProfile;
          
          return ListView(
            children: [
              _buildSection('Compte'),
              _buildSettingItem(
                context, 
                Icons.person_outline, 
                'Informations personnelles',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
              _buildSettingItem(
                context, 
                Icons.lock_outline, 
                'Mot de passe et sécurité',
                onTap: () => _showPasswordUpdateDialog(context),
              ),
              _buildSettingItem(
                context, 
                Icons.notifications_none, 
                'Notifications',
                isSwitch: true,
                switchValue: profile?.notificationsEnabled ?? true,
                onSwitchChanged: (value) {
                  profileProvider.updateSettings(notificationsEnabled: value);
                },
              ),
              
              _buildSection('Préférences'),
              _buildSettingItem(
                context, 
                Icons.language, 
                'Langue', 
                trailing: 'Français',
                onTap: () => _showLanguageDialog(context),
              ),
              _buildSettingItem(
                context, 
                Icons.dark_mode_outlined, 
                'Mode sombre', 
                isSwitch: true,
                switchValue: themeProvider.isDarkMode,
                onSwitchChanged: (value) {
                  themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  profileProvider.updateSettings(isDarkMode: value);
                },
              ),
              
              _buildSection('Assistance'),
              _buildSettingItem(
                context, 
                Icons.help_outline, 
                'Aide et support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                  );
                },
              ),
              _buildSettingItem(
                context, 
                Icons.info_outline, 
                'À propos',
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
              
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
                    backgroundColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[900] 
                        : Colors.white,
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
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white38 
                        : AppColors.textLight, 
                    fontSize: 12
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              trailing: const Icon(Icons.check, color: AppColors.primaryOrange),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anglais sera bientôt disponible !')),
                );
              },
            ),
          ],
        ),
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

  Widget _buildSettingItem(
    BuildContext context, 
    IconData icon, 
    String title, {
    String? trailing, 
    bool isSwitch = false, 
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(
          icon, 
          color: isDark ? Colors.white70 : AppColors.textPrimary, 
          size: 22
        ),
        title: Text(
          title, 
          style: AppTypography.bodyMedium.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: isSwitch 
          ? Switch(
              value: switchValue, 
              onChanged: onSwitchChanged, 
              activeColor: AppColors.primaryOrange,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) 
                  Text(
                    trailing, 
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppColors.textSecondary, 
                      fontSize: 12
                    )
                  ),
                Icon(
                  Icons.chevron_right, 
                  color: isDark ? Colors.white38 : AppColors.textLight, 
                  size: 20
                ),
              ],
            ),
        onTap: isSwitch ? null : (onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title sera disponible prochainement !'),
              duration: const Duration(seconds: 2),
            ),
          );
        }),
      ),
    );
  }

  void _showPasswordUpdateDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (passwordController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
                  );
                  return;
                }
                if (passwordController.text.length < 6) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le mot de passe doit faire au moins 6 caractères')),
                  );
                  return;
                }

                setDialogState(() => isLoading = true);
                final success = await context.read<AuthProvider>().updatePassword(passwordController.text);
                setDialogState(() => isLoading = false);

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mot de passe mis à jour !'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  } else {
                    final error = context.read<AuthProvider>().error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error ?? 'Une erreur est survenue'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }
}
