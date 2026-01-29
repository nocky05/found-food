import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/posts/domain/models/comment_model.dart';

class PostRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer le fil d'actualité (Posts avec Lieux, Auteurs et Stats)
  Future<List<Post>> getFeed() async {
    final userId = _supabase.auth.currentUser?.id;
    try {
      // 1. Utiliser la vue consolidée qui contient déjà les profils, lieux et médias
      // On sélectionne TOUT de la vue
      final response = await _supabase
          .from('posts_with_stats')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;
      
      // 2. Récupérer les IDs des posts likés et favorisés par l'utilisateur
      List<String> userLikedPostIds = [];
      List<String> userFavoritedPostIds = [];
      
      if (userId != null) {
        try {
          final likesResponse = await _supabase
              .from('likes')
              .select('post_id')
              .eq('user_id', userId);
          userLikedPostIds = (likesResponse as List).map((l) => l['post_id'] as String).toList();

          final favoritesResponse = await _supabase
              .from('favorites')
              .select('post_id')
              .eq('user_id', userId);
          userFavoritedPostIds = (favoritesResponse as List).map((f) => f['post_id'] as String).toList();
        } catch (e) {
          print("Note: Erreur lors de la récupération des likes/favoris: $e");
        }
      }

      // 3. Mapper les résultats (les counts sont déjà inclus dans la vue)
      return data.map((json) {
        final postJson = Map<String, dynamic>.from(json);
        final postId = postJson['id'];
        
        postJson['is_liked'] = userLikedPostIds.contains(postId);
        postJson['is_favorited'] = userFavoritedPostIds.contains(postId);
        
        return Post.fromJson(postJson);
      }).toList();
    } catch (e) {
      print('Erreur critique getFeed: $e');
      rethrow;
    }
  }

  // Liker/Unliker un post via RPC atomique
  Future<bool> toggleLike(String postId) async {
    try {
      final result = await _supabase.rpc(
        'toggle_like',
        params: {'target_post_id': postId},
      );
      return result as bool;
    } catch (e) {
      print('Erreur RPC toggleLike: $e');
      rethrow;
    }
  }

  // Ajouter un commentaire
  Future<void> addComment(String postId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Créer un nouveau post avec upload réel
  Future<void> createPost({
    required String placeId,
    required String content,
    required double? budgetSpent,
    required double? tripCost,
    required int? tripDuration,
    required String? transportMode,
    required List<XFile> mediaFiles, 
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    try {
      // 1. Insérer le post
      final postResponse = await _supabase.from('posts').insert({
        'author_id': userId,
        'place_id': placeId,
        'content': content,
        'budget_spent': budgetSpent,
        'trip_cost': tripCost,
        'trip_duration': tripDuration,
        'transport_mode': transportMode,
      }).select().single();

      final postId = postResponse['id'];

      // 2. Uploader les médias
      for (var xFile in mediaFiles) {
        final fileName = '${postId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await xFile.readAsBytes();
        
        // Upload réel vers Supabase Storage
        await _supabase.storage.from('posts').uploadBinary(
          fileName, 
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        
        final publicUrl = _supabase.storage.from('posts').getPublicUrl(fileName);

        await _supabase.from('post_media').insert({
          'post_id': postId,
          'type': 'image',
          'url': publicUrl,
        });
      }
    } catch (e) {
      print('Erreur upload/save: $e');
      rethrow;
    }
  }

  // Récupérer les commentaires d'un post
  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles:user_id (username, full_name, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print('Erreur getComments: $e');
      return [];
    }
  }
}
