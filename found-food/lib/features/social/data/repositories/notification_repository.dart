import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  // Fetch notifications for the current user
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('notifications')
          .select('''
            *,
            profiles:actor_id (username, full_name, avatar_url)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final notifications = List<Map<String, dynamic>>.from(response);

      // Pour les notifications de type 'comment', on récupère le contenu du commentaire
      for (var n in notifications) {
        if (n['type'] == 'comment' && n['entity_id'] != null) {
          try {
            final commentResponse = await _supabase
                .from('comments')
                .select('content')
                .eq('post_id', n['entity_id'])
                .eq('user_id', n['actor_id'])
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();
            
            if (commentResponse != null) {
              n['comment_content'] = commentResponse['content'];
            }
          } catch (e) {
            print('Erreur lors de la récupération du contenu du commentaire: $e');
          }
        }
      }

      return notifications;
    } catch (e) {
      print('Error fetching notifications (table might be missing): $e');
      return [];
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking notifications as read: $e');
      throw e;
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e;
    }
  }
}
