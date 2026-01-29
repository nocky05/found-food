import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:found_food/features/places/domain/repositories/place_repository.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';

class MapProvider with ChangeNotifier {
  final PlaceRepository _repository = PlaceRepository();

  List<Place> _places = [];
  Set<Marker> _markers = {};
  Place? _selectedPlace;
  bool _isLoading = false;
  GoogleMapController? _mapController;
  
  // Position par défaut (Abidjan)
  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(5.3484, -4.0244),
    zoom: 12.0,
  );

  List<Place> get places => _places;
  Set<Marker> get markers => _markers;
  Place? get selectedPlace => _selectedPlace;
  bool get isLoading => _isLoading;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> fetchPlaces() async {
    _isLoading = true;
    notifyListeners();

    try {
      _places = await _repository.getAllPlaces();
      _generateMarkers();
      await moveToUserLocation();
    } catch (e) {
      print('Erreur MapProvider.fetchPlaces: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveToUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );
    } catch (e) {
      print('Erreur Geolocation: $e');
    }
  }

  void searchAndMoveTo(String query) {
    if (query.isEmpty) return;
    
    // Recherche dans les lieux chargés localement
    try {
      final result = _places.firstWhere(
        (p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
               (p.address.toLowerCase().contains(query.toLowerCase())),
      );

      if (result.latitude != null && result.longitude != null) {
        _selectedPlace = result;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(result.latitude!, result.longitude!),
            16.0,
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      // Pas de résultat local trouvé
      print('Aucun lieu trouvé pour: $query');
    }
  }

  void _generateMarkers() {
    _markers = _places.where((p) => p.latitude != null && p.longitude != null).map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude!, place.longitude!),
        infoWindow: InfoWindow(title: place.name, snippet: place.category),
        onTap: () {
          _selectedPlace = place;
          notifyListeners();
        },
      );
    }).toSet();
  }

  void selectPlace(Place? place) {
    _selectedPlace = place;
    notifyListeners();
  }
}
