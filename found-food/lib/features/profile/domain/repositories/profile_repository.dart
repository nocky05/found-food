import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/profile/domain/models/profile_model.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer le profil d'un utilisateur spécifique
  Future<Profile> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour le profil actuel
  Future<void> updateProfile(Profile profile) async {
    try {
      // On retire les champs null pour ne pas écraser des données existantes avec null involontairement
      final data = profile.toJson();
      data.removeWhere((key, value) => value == null);
      
      data['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', profile.id);
    } catch (e) {
      rethrow;
    }
  }

  // Upload Avatar
  Future<String> uploadAvatar(String userId, Uint8List bytes) async {
    try {
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload
      await _supabase.storage.from('profiles').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      // Get Public URL
      return _supabase.storage.from('profiles').getPublicUrl(fileName);
    } catch (e) {
      print('Erreur upload avatar: $e');
      rethrow;
    }
  }

  // Récupérer les posts d'un utilisateur spécifique
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts_with_stats')
          .select()
          .eq('author_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;
      
      // Pour les posts de l'utilsateur, on sait déjà qui est l'auteur
      // et on peut vérifier is_liked si on le souhaite (optionnel ici)
      return data.map((json) => Post.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les favoris d'un utilisateur spécifique
  Future<List<Post>> getFavorites(String userId) async {
    try {
      // 1. Récupérer les IDs des posts favoris
      final favResponse = await _supabase
          .from('favorites')
          .select('post_id')
          .eq('user_id', userId);
      
      final List<String> favoriteIds = (favResponse as List).map((f) => f['post_id'] as String).toList();
      
      if (favoriteIds.isEmpty) return [];

      // 2. Récupérer les détails via la vue filtrée par ces IDs
      final response = await _supabase
          .from('posts_with_stats')
          .select()
          .filter('id', 'in', favoriteIds)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;
      return data.map((json) {
        final postJson = Map<String, dynamic>.from(json);
        postJson['is_favorited'] = true; // Forcé car on est dans les favoris
        return Post.fromJson(postJson);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Ajouter/Retirer des favoris via RPC atomique
  Future<bool> toggleFavorite(String postId) async {
    try {
      final result = await _supabase.rpc(
        'toggle_favorite',
        params: {'target_post_id': postId},
      );
      return result as bool;
    } catch (e) {
      print('Erreur RPC toggleFavorite: $e');
      rethrow;
    }
  }
}
