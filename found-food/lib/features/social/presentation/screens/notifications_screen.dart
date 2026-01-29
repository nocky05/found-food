import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données fictives pour les notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'user': 'Marc Dupont',
        'action': 'a aimé votre post sur Le Petit Bistro',
        'time': '2m',
        'avatar': 'https://i.pravatar.cc/150?u=marc',
        'type': 'like',
        'isNew': true,
      },
      {
        'user': 'Julie Laroche',
        'action': 'a commencé à vous suivre',
        'time': '15m',
        'avatar': 'https://i.pravatar.cc/150?u=julie',
        'type': 'follow',
        'isNew': true,
      },
      {
        'user': 'Sophie Gourmet',
        'action': 'a commenté : "Ça a l\'air délicieux !"',
        'time': '1h',
        'avatar': 'https://i.pravatar.cc/300?u=foundfood',
        'type': 'comment',
        'isNew': false,
      },
      {
        'user': 'Paul Martin',
        'action': 'a commencé à vous suivre',
        'time': '3h',
        'avatar': 'https://i.pravatar.cc/150?u=paul',
        'type': 'follow',
        'isNew': false,
      },
    ];

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
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 70, color: AppColors.dividerColor),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            color: notification['isNew'] ? AppColors.primaryOrange.withOpacity(0.03) : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppDimensions.paddingMD),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(notification['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                          children: [
                            TextSpan(
                              text: '${notification['user']} ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: notification['action']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'],
                        style: AppTypography.caption.copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
                if (notification['type'] == 'follow')
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryOrange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Suivre en retour', style: TextStyle(color: AppColors.primaryOrange, fontSize: 11)),
                  ),
                if (notification['type'] == 'like' || notification['type'] == 'comment')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://picsum.photos/40/40?random=$index',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
