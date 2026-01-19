class AppConstants {
  // App Info
  static const String appName = 'Found-Food';
  static const String appTagline = 'Découvrez et partagez vos expériences';
  
  // Place Types
  static const String placeTypeRestaurant = 'restaurant';
  static const String placeTypeParc = 'parc';
  static const String placeTypePlage = 'plage';
  static const String placeTypePiscine = 'piscine';
  static const String placeTypeIle = 'ile';
  static const String placeTypeEspacePublic = 'espace_public';
  static const String placeTypeAutre = 'autre';
  
  static const List<String> placeTypes = [
    placeTypeRestaurant,
    placeTypeParc,
    placeTypePlage,
    placeTypePiscine,
    placeTypeIle,
    placeTypeEspacePublic,
    placeTypeAutre,
  ];
  
  static const Map<String, String> placeTypeLabels = {
    placeTypeRestaurant: '🍽️ Restaurant',
    placeTypeParc: '🌳 Parc',
    placeTypePlage: '🏖️ Plage',
    placeTypePiscine: '🏊 Piscine',
    placeTypeIle: '🏝️ Île',
    placeTypeEspacePublic: '🏛️ Espace public',
    placeTypeAutre: '📍 Autre',
  };
  
  // Price Ranges (FCFA - Franc CFA)
  static const String priceRangeLow = 'FCFA';
  static const String priceRangeMedium = 'FCFA FCFA';
  static const String priceRangeHigh = 'FCFA FCFA FCFA';
  
  static const List<String> priceRanges = [
    priceRangeLow,
    priceRangeMedium,
    priceRangeHigh,
  ];
  
  // Price Level Descriptions
  static const Map<String, String> priceRangeLabels = {
    priceRangeLow: 'Économique (< 5000 FCFA)',
    priceRangeMedium: 'Moyen (5000-15000 FCFA)',
    priceRangeHigh: 'Élevé (> 15000 FCFA)',
  };
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 150;
  static const int maxCaptionLength = 500;
  static const int maxPlaceNameLength = 100;
  
  // Media
  static const int maxPhotosPerPost = 10;
  static const int maxPhotosPerPlace = 10;
  static const int maxVideoDurationSeconds = 60;
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int commentsPageSize = 50;
  
  // Search
  static const double minSearchRadius = 1.0; // km
  static const double maxSearchRadius = 100.0; // km
  static const List<double> searchRadiusOptions = [1, 5, 10, 25, 50, 100];
  
  // Status/Stories
  static const int statusDurationHours = 24;
  
  // Rate Limiting
  static const int maxPlacesPerDay = 10;
  static const int maxPostsPerDay = 20;
  
  // Error Messages
  static const String errorGeneric = 'Une erreur est survenue. Veuillez réessayer.';
  static const String errorNetwork = 'Problème de connexion. Vérifiez votre réseau.';
  static const String errorAuth = 'Erreur d\'authentification. Reconnectez-vous.';
  static const String errorNotFound = 'Ressource introuvable.';
  static const String errorPermission = 'Permission refusée.';
  
  // Success Messages
  static const String successPlaceAdded = 'Lieu ajouté avec succès !';
  static const String successPostCreated = 'Post publié avec succès !';
  static const String successProfileUpdated = 'Profil mis à jour !';
  static const String successFollowed = 'Vous suivez maintenant cet utilisateur';
  static const String successUnfollowed = 'Vous ne suivez plus cet utilisateur';
}
