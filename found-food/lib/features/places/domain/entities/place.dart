class Place {
  final String id;
  final String name;
  final String type; // Restaurant, Parc, etc.
  final double latitude;
  final double longitude;
  final String address;
  final String? phoneNumber;
  final List<String> photoUrls;
  final String? averageBudget; // €, €€, €€€
  
  // Trip Info
  final String? tripDescription;
  final double? tripCost;
  final int? tripDurationMinutes;
  final String? transportMode;

  // Menu (Photo of the card)
  final String? menuPhotoUrl;

  const Place({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phoneNumber,
    required this.photoUrls,
    this.averageBudget,
    this.tripDescription,
    this.tripCost,
    this.tripDurationMinutes,
    this.transportMode,
    this.menuPhotoUrl,
  });
}
