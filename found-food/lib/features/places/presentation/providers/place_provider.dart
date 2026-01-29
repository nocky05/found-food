import 'package:flutter/material.dart';
import 'package:found_food/features/places/domain/repositories/place_repository.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceRepository _placeRepository = PlaceRepository();
  
  Place? _currentPlace;
  List<Post> _placePosts = [];
  bool _isLoading = false;
  String? _error;

  Place? get currentPlace => _currentPlace;
  List<Post> get placePosts => _placePosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlaceDetails(String id) async {
    _isLoading = true;
    _error = null;
    _currentPlace = null;
    _placePosts = [];
    notifyListeners();

    try {
      _currentPlace = await _placeRepository.getPlaceById(id);
      _placePosts = await _placeRepository.getPostsForPlace(id);
    } catch (e) {
      _error = "Impossible de charger les détails du lieu";
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
