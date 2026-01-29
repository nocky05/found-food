import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/posts/domain/models/comment_model.dart';
import 'package:found_food/features/posts/domain/repositories/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  
  List<Post> _feedPosts = [];
  List<Comment> _currentPostComments = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get feedPosts => _feedPosts;
  List<Comment> get currentPostComments => _currentPostComments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger le flux
  Future<void> fetchFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feedPosts = await _postRepository.getFeed();
    } catch (e) {
      _error = "Impossible de charger le flux d'actualité";
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer un post
  Future<bool> createPost({
    required String placeId,
    required String content,
    required double? budgetSpent,
    required double? tripCost,
    required int? tripDuration,
    required String? transportMode,
    required List<XFile> mediaFiles,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _postRepository.createPost(
        placeId: placeId,
        content: content,
        budgetSpent: budgetSpent,
        tripCost: tripCost,
        tripDuration: tripDuration,
        transportMode: transportMode,
        mediaFiles: mediaFiles,
      );
      await fetchFeed(); // Rafraîchir après publication
      return true;
    } catch (e) {
      _error = "Erreur lors de la publication";
      print(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Liker/Unliker un post
  Future<void> toggleLike(Post post) async {
    // Mise à jour optimiste
    final wasLiked = post.isLiked;
    // Mise à jour locale
    post.isLiked = !wasLiked;
    if (post.isLiked) {
      post.likeCount += 1;
    } else {
      post.likeCount -= 1;
    }
    
    notifyListeners();

    try {
      await _postRepository.toggleLike(post.id);
      // On ne rafraîchit PAS tout le feed pour éviter le spinner
      // L'optimistic update suffit pour l'UX immédiate
    } catch (e) {
      // Revenir à l'état précédent en cas d'erreur
      post.isLiked = wasLiked;
      if (post.isLiked) {
        post.likeCount += 1; // restaurer si on avait décrémenté
      } else {
        post.likeCount -= 1; // restaurer si on avait incrémenté
      }
      notifyListeners();
      print("Erreur like: $e");
    }
  }

  // Ajouter un commentaire
  Future<void> addComment(String postId, String content) async {
    try {
      await _postRepository.addComment(postId, content);
      await fetchComments(postId); // Rafraîchir la liste après ajout local
      await fetchFeed(); // Rafraîchir pour le compteur sur la home
    } catch (e) {
      _error = "Impossible d'ajouter le commentaire";
      notifyListeners();
    }
  }

  // Charger les commentaires d'un post
  Future<void> fetchComments(String postId) async {
    try {
      _currentPostComments = await _postRepository.getComments(postId);
      notifyListeners();
    } catch (e) {
      print("Erreur fetchComments: $e");
    }
  }
}
