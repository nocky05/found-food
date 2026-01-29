import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';

class PlaceRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadPlaceImage(XFile xFile, String folder) async {
    final fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await xFile.readAsBytes();
    
    await _supabase.storage.from('places').uploadBinary(
      fileName, 
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    
    return _supabase.storage.from('places').getPublicUrl(fileName);
  }

  // Récupérer tous les lieux (pour la carte)
  Future<List<Place>> getAllPlaces() async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .order('name');
      
      return (response as List).map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les détails d'un lieu
  Future<Place> getPlaceById(String id) async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .eq('id', id)
          .single();

      return Place.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les derniers posts pour un lieu spécifique
  Future<List<Post>> getPostsForPlace(String placeId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:author_id (username, full_name, avatar_url),
            post_media (url, type)
          ''')
          .eq('place_id', placeId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Créer un nouveau lieu
  Future<String> createPlace({
    required String name,
    required String address,
    String? phone,
    String? category,
    String? budgetRange,
    String? menuUrl,
  }) async {
    try {
      final response = await _supabase.from('places').insert({
        'name': name,
        'address': address,
        'phone': phone,
        'category': category,
        'budget_range': budgetRange,
        'menu_url': menuUrl,
      }).select('id').single();

      return response['id'];
    } catch (e) {
      rethrow;
    }
  }
  // Rechercher des lieux par nom
  Future<List<Place>> searchPlaces(String query) async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .ilike('name', '%$query%')
          .limit(10);
      
      return (response as List).map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      print('Erreur searchPlaces: $e');
      return [];
    }
  }
}
