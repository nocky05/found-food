import 'dart:async';
import 'package:flutter/material.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/search/data/repositories/search_repository.dart';

class SearchProvider with ChangeNotifier {
  final SearchRepository _repository;
  
  SearchProvider(this._repository);

  List<Place> _results = [];
  bool _isLoading = false;
  String _query = '';
  Timer? _debounce;

  List<Place> get results => _results;
  bool get isLoading => _isLoading;
  String get query => _query;

  void onQueryChanged(String query) {
    _query = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _repository.searchPlaces(query);
    } catch (e) {
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
