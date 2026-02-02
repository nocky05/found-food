import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/social/presentation/providers/notification_provider.dart';
import 'package:found_food/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<NotificationProvider>().fetchNotifications()
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.primaryOrange),
            tooltip: 'Tout marquer comme lu',
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('Aucune notification pour le moment.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchNotifications();
            },
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                final profiles = notification['profiles'] ?? {};
                final actorName = profiles['full_name'] ?? 'Utilisateur';
                final avatarUrl = profiles['avatar_url'];
                final type = notification['type'];
                final isRead = notification['is_read'] ?? false;
                final createdAt = DateTime.tryParse(notification['created_at']) ?? DateTime.now();

                String actionText = '';
                if (type == 'like') actionText = 'a aimé votre publication';
                else if (type == 'comment') actionText = 'a commenté votre publication';
                else if (type == 'follow') actionText = 'a commencé à vous suivre';

                return Container(
                  color: !isRead ? AppColors.primaryOrange.withOpacity(0.05) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppDimensions.paddingMD),
                  child: InkWell(
                    onTap: () {
                      if (!isRead) {
                        provider.markAsRead(notification['id']);
                      }
                      
                      if (type == 'follow') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublicProfileScreen(userId: notification['actor_id']),
                          ),
                        );
                      } else if (type == 'like' || type == 'comment') {
                        if (notification['entity_id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceDetailsScreen(postId: notification['entity_id']),
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                              ? NetworkImage(avatarUrl) 
                              : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty) 
                              ? const Icon(Icons.person) 
                              : null,
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
                                      text: '$actorName ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: actionText),
                                  ],
                                ),
                              ),
                              if (type == 'comment' && notification['comment_content'] != null)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '"${notification['comment_content']}"',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? Colors.white70 : Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                timeago.format(createdAt, locale: 'fr'),
                                style: AppTypography.caption.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white38 
                                      : AppColors.textLight
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (type == 'follow')
                          const Icon(Icons.person_add, color: AppColors.primaryOrange, size: 20),
                        if (type == 'like')
                           const Icon(Icons.favorite, color: Colors.pink, size: 20),
                        if (type == 'comment')
                           const Icon(Icons.comment, color: Colors.blue, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
