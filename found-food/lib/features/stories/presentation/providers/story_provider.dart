import 'package:flutter/material.dart';
import 'package:found_food/features/stories/data/repositories/story_repository.dart';
import 'package:found_food/features/stories/domain/models/story_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryProvider with ChangeNotifier {
  final StoryRepository _repository = StoryRepository();

  List<UserStories> _userStories = [];
  bool _isLoading = false;
  String? _error;

  List<UserStories> get userStories => _userStories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Vérifier si l'utilisateur actuel a des stories actives
  bool get currentUserHasStories {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return false;
    return _userStories.any((us) => us.userId == currentUserId && us.stories.isNotEmpty);
  }

  // Vérifier si un utilisateur spécifique a des stories actives
  bool hasActiveStory(String userId) {
    return _userStories.any((us) => us.userId == userId && us.stories.isNotEmpty);
  }

  // Obtenir les stories de l'utilisateur actuel
  UserStories? get currentUserStories {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return null;
    try {
      return _userStories.firstWhere((us) => us.userId == currentUserId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 StoryProvider: Fetching stories...');
      _userStories = await _repository.getActiveStories();
      print('✅ StoryProvider: Fetched ${_userStories.length} user stories');
      
      // Log current user stories
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      print('👤 StoryProvider: Current user ID: $currentUserId');
      print('📊 StoryProvider: Current user has stories: $currentUserHasStories');
      
      if (currentUserHasStories) {
        final myStories = currentUserStories;
        print('📸 StoryProvider: Current user has ${myStories?.stories.length ?? 0} stories');
      }
    } catch (e) {
      print('❌ StoryProvider.fetchStories ERROR: $e');
      _error = 'Impossible de charger les stories';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStory(XFile file) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createStory(file);
      await fetchStories(); // Rafraîchir
    } catch (e) {
      _error = 'Erreur lors de la création de la story';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
