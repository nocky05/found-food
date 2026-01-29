import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/stories/domain/models/story_model.dart';
import 'package:image_picker/image_picker.dart';

class StoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer les stories actives groupées par utilisateur
  Future<List<UserStories>> getActiveStories() async {
    try {
      print('🔍 StoryRepository: Fetching active stories...');
      final response = await _supabase
          .from('active_stories')
          .select()
          .order('created_at', ascending: true);

      print('📦 StoryRepository: Response received: ${response.toString()}');
      final List<dynamic> data = response as List;
      print('📊 StoryRepository: Found ${data.length} stories');
      
      final stories = data.map((json) => Story.fromJson(json)).toList();

      // Grouper par utilisateur
      final Map<String, List<Story>> grouped = {};
      for (var story in stories) {
        grouped.putIfAbsent(story.userId, () => []).add(story);
      }

      print('👥 StoryRepository: Grouped into ${grouped.length} users');
      return grouped.entries.map((entry) {
        final userStories = entry.value;
        return UserStories(
          userId: entry.key,
          username: userStories.first.username ?? 'Utilisateur',
          avatarUrl: userStories.first.avatarUrl,
          stories: userStories,
        );
      }).toList();
    } catch (e) {
      print('❌ StoryRepository.getActiveStories ERROR: $e');
      return [];
    }
  }

  // Créer une nouvelle story
  Future<void> createStory(XFile xFile, {String type = 'image'}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      print('📤 StoryRepository: Creating story for user ${user.id}');
      
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await xFile.readAsBytes();

      print('📤 StoryRepository: Uploading to bucket "stories" with path: $fileName');
      
      // 1. Upload le média
      await _supabase.storage.from('stories').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      print('✅ StoryRepository: Upload successful');

      final mediaUrl = _supabase.storage.from('stories').getPublicUrl(fileName);
      print('🔗 StoryRepository: Public URL: $mediaUrl');

      // 2. Créer l'entrée en base
      final insertedData = await _supabase.from('stories').insert({
        'user_id': user.id,
        'media_url': mediaUrl,
        'media_type': type,
      }).select();
      
      print('✅ StoryRepository: Story created in database: $insertedData');
    } catch (e) {
      print('❌ StoryRepository.createStory ERROR: $e');
      rethrow;
    }
  }
}
