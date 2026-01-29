import 'package:supabase_flutter/supabase_flutter.dart';

class FollowRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Suivre ou ne plus suivre un utilisateur (via la fonction RPC sécurisée)
  Future<bool> toggleFollow(String targetUserId) async {
    try {
      final result = await _supabase.rpc(
        'toggle_follow',
        params: {'target_user_id': targetUserId},
      );
      return result as bool;
    } catch (e) {
      throw Exception('Erreur lors du changement de statut de suivi: $e');
    }
  }

  // Vérifier si je suis déjà cet utilisateur
  Future<bool> isFollowing(String targetUserId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return false;

    try {
      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      // Si erreur, on assume qu'on ne suit pas pour ne pas bloquer l'UI
      print('Erreur isFollowing: $e');
      return false;
    }
  }

  // Obtenir le nombre de followers d'un utilisateur
  Future<int> getFollowersCount(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .count()
          .eq('following_id', userId);
      return response;
    } catch (e) {
      print('Erreur getFollowersCount: $e');
      return 0;
    }
  }

  // Obtenir le nombre de personnes suivies par un utilisateur
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .count()
          .eq('follower_id', userId);
      return response;
    } catch (e) {
      print('Erreur getFollowingCount: $e');
      return 0;
    }
  }
  // Obtenir la liste des abonnés (Followers)
  Future<List<Map<String, dynamic>>> getFollowersList(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('follower_id, profiles:follower_id(username, full_name, avatar_url)')
          .eq('following_id', userId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getFollowersList: $e');
      return [];
    }
  }

  // Obtenir la liste des abonnements (Following)
  Future<List<Map<String, dynamic>>> getFollowingList(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('following_id, profiles:following_id(username, full_name, avatar_url)')
          .eq('follower_id', userId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getFollowingList: $e');
      return [];
    }
  }
}
