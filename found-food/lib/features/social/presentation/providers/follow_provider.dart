import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/social/data/repositories/follow_repository.dart';

class FollowProvider extends ChangeNotifier {
  final FollowRepository _repository = FollowRepository();
  
  // Cache local des statuts de follow (userId -> isFollowing)
  // Cela permet une UI réactive sans requêter l'API à chaque build
  final Map<String, bool> _followingStatus = {};
  
  // Cache pour les compteurs (userId -> {followers: int, following: int})
  final Map<String, Map<String, int>> _userStats = {};

  bool isFollowing(String userId) => _followingStatus[userId] ?? false;
  
  int getFollowersCount(String userId) => _userStats[userId]?['followers'] ?? 0;
  int getFollowingCount(String userId) => _userStats[userId]?['following'] ?? 0;

  // Initialiser le statut de follow pour un utilisateur (appelé quand on affiche un profil ou une carte)
  Future<void> checkFollowStatus(String userId) async {
    if (_followingStatus.containsKey(userId)) return; // Déjà chargé

    try {
      final status = await _repository.isFollowing(userId);
      _followingStatus[userId] = status;
      notifyListeners();
    } catch (e) {
      print('Erreur checkFollowStatus: $e');
    }
  }
  
  // Charger les stats (compteurs) pour un profil
  Future<void> fetchUserStats(String userId) async {
    try {
      final followers = await _repository.getFollowersCount(userId);
      final following = await _repository.getFollowingCount(userId);
      
      _userStats[userId] = {
        'followers': followers,
        'following': following,
      };
      notifyListeners();
    } catch (e) {
      print('Erreur fetchUserStats: $e');
    }
  }

  // Toggle follow avec mise à jour optimiste
  Future<bool> toggleFollow(String userId) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    // Empêcher de se suivre soi-même
    if (userId == currentUserId) return false;

    final currentStatus = isFollowing(userId);
    
    // 1. Mise à jour optimiste immédiate
    _followingStatus[userId] = !currentStatus;
    
    // Mise à jour optimiste des compteurs (si chargés)
    // 1a. Compteur de followers de la cible
    if (_userStats.containsKey(userId)) {
      final currentFollowers = _userStats[userId]!['followers']!;
      _userStats[userId]!['followers'] = currentStatus 
          ? currentFollowers - 1 
          : currentFollowers + 1;
    }

    // 1b. Compteur de following de l'utilisateur actuel
    if (currentUserId != null && _userStats.containsKey(currentUserId)) {
      final currentFollowing = _userStats[currentUserId]!['following']!;
      _userStats[currentUserId]!['following'] = currentStatus 
          ? currentFollowing - 1 
          : currentFollowing + 1;
    }
    
    notifyListeners();

    try {
      // 2. Appel API réel
      final newStatus = await _repository.toggleFollow(userId);
      
      // 3. Si le résultat API diffère de notre prévision (rare), on corrige
      if (newStatus != !currentStatus) {
        _followingStatus[userId] = newStatus;
        // Correction du compteur (retour à l'état initial + ajustement réel)
        if (_userStats.containsKey(userId)) await fetchUserStats(userId);
        if (currentUserId != null && _userStats.containsKey(currentUserId)) await fetchUserStats(currentUserId);
        notifyListeners();
      }
      return newStatus;
    } catch (e) {
      // 4. En cas d'erreur, rollback
      _followingStatus[userId] = currentStatus;
      
      if (_userStats.containsKey(userId)) {
        final currentFollowers = _userStats[userId]!['followers']!;
        _userStats[userId]!['followers'] = currentStatus 
            ? currentFollowers + 1 
            : currentFollowers - 1;
      }

      if (currentUserId != null && _userStats.containsKey(currentUserId)) {
        final currentFollowing = _userStats[currentUserId]!['following']!;
        _userStats[currentUserId]!['following'] = currentStatus 
            ? currentFollowing + 1 
            : currentFollowing - 1;
      }
      
      notifyListeners();
      return currentStatus;
    }
  }
  // Récupérer la liste des followers pour l'UI
  Future<List<Map<String, dynamic>>> fetchFollowersList(String userId) async {
    return await _repository.getFollowersList(userId);
  }

  // Récupérer la liste des following pour l'UI
  Future<List<Map<String, dynamic>>> fetchFollowingList(String userId) async {
    return await _repository.getFollowingList(userId);
  }
}
