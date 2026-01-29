import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';

class SearchRepository {
  final SupabaseClient _supabase;

  SearchRepository(this._supabase);

  Future<List<Place>> searchPlaces(String query) async {
    try {
      final response = await _supabase.rpc(
        'search_places',
        params: {'query_text': query},
      );

      final List<dynamic> data = response as List;
      return data.map((json) => Place.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      print('Erreur SearchRepository: $e');
      return [];
    }
  }
}
