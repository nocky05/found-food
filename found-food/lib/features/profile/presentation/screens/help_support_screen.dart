import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpItem(
            context,
            Icons.email_outlined,
            'Contactez-nous',
            'support@foundfood.com',
            onTap: () {
              // TODO: Implement email launch
            },
          ),
          const Divider(),
          _buildHelpItem(
            context,
            Icons.question_answer_outlined,
            'FAQ',
            'Questions fréquemment posées',
          ),
          const Divider(),
          _buildHelpItem(
            context,
            Icons.description_outlined,
            'Conditions d\'utilisation',
            'Lire nos conditions',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryOrange),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bientôt disponible')),
        );
      },
    );
  }
}
