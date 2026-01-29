import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/profile/domain/models/profile_model.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/profile/domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  Profile? _userProfile;
  List<Post> _userPosts = [];
  List<Post> _favoritePosts = [];
  bool _isLoading = false;
  String? _error;

  Profile? get userProfile => _userProfile;
  List<Post> get userPosts => _userPosts;
  List<Post> get favoritePosts => _favoritePosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger toutes les données du profil
  Future<void> fetchProfileData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Profil (Indispensable)
      try {
        _userProfile = await _profileRepository.getProfile(userId);
      } catch (e) {
        _error = "Profil non trouvé. Avez-vous exécuté le script SQL ?";
        print("Erreur Profile: $e");
      }

      // 2. Posts (Optionnel pour l'affichage)
      try {
        _userPosts = await _profileRepository.getUserPosts(userId);
      } catch (e) {
        print("Erreur UserPosts (table peut-être manquante): $e");
      }

      // 3. Favoris (Optionnel pour l'affichage)
      try {
        _favoritePosts = await _profileRepository.getFavorites(userId);
      } catch (e) {
        print("Erreur Favorites (table peut-être manquante): $e");
      }
    } catch (e) {
      _error = "Erreur lors du chargement des données";
      print("Erreur ProfileProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le profil
  Future<bool> updateProfile(Profile updatedProfile) async {
    try {
      await _profileRepository.updateProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Erreur lors de la mise à jour du profil";
      notifyListeners();
      return false;
    }
  }

  // Upload Avatar
  Future<String?> uploadAvatar(Uint8List bytes) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final url = await _profileRepository.uploadAvatar(userId, bytes);
      return url;
    } catch (e) {
      _error = "Erreur lors de l'upload de l'avatar";
      notifyListeners();
      return null;
    }
  }

  // Ajouter/Retirer des favoris
  Future<void> toggleFavorite(Post post) async {
    final wasFavorited = post.isFavorited;
    
    // Mise à jour optimiste locale
    post.isFavorited = !wasFavorited;
    if (post.isFavorited) {
      _favoritePosts.insert(0, post);
    } else {
      _favoritePosts.removeWhere((p) => p.id == post.id);
    }
    notifyListeners();

    try {
      final finalIsFavorited = await _profileRepository.toggleFavorite(post.id);
      
      // Synchronisation réelle si différente de l'optimiste
      if (post.isFavorited != finalIsFavorited) {
        post.isFavorited = finalIsFavorited;
        if (post.isFavorited) {
          if (!_favoritePosts.any((p) => p.id == post.id)) _favoritePosts.insert(0, post);
        } else {
          _favoritePosts.removeWhere((p) => p.id == post.id);
        }
        notifyListeners();
      }
    } catch (e) {
      // Rollback en cas d'erreur
      post.isFavorited = wasFavorited;
      if (wasFavorited) {
         if (!_favoritePosts.any((p) => p.id == post.id)) _favoritePosts.insert(0, post);
      } else {
        _favoritePosts.removeWhere((p) => p.id == post.id);
      }
      notifyListeners();
      print("Erreur toggleFavorite: $e");
    }
  }
}
