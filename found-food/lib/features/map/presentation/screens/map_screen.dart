import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/map/presentation/providers/map_provider.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().fetchPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // True Google Map
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: MapProvider.initialPosition,
                  markers: provider.markers,
                  onMapCreated: (controller) => provider.setMapController(controller),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (_) => provider.selectPlace(null),
                ),
              ),
              
              // Header - Barre de recherche
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: _buildHeader(context, provider),
              ),

              // Bouton "Ma position"
              Positioned(
                bottom: provider.selectedPlace != null ? 180 : 20,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => provider.moveToUserLocation(),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: AppColors.primaryOrange),
                ),
              ),
              
              // Bottom Card - Détail du lieu sélectionné
              if (provider.selectedPlace != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _buildPlaceCard(context, provider.selectedPlace!),
                ),

              if (provider.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MapProvider provider) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: AppColors.cardShadow,
            ),
            child: TextField(
              onSubmitted: (value) => provider.searchAndMoveTo(value),
              decoration: const InputDecoration(
                hintText: 'Rechercher un lieu ou restaurant...',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.primaryOrange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place place) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.surfaceColor,
                  child: const Icon(Icons.restaurant, color: AppColors.primaryOrange, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      place.category ?? 'Restaurant',
                      style: const TextStyle(color: AppColors.primaryOrange, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.address,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigation GPS logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigation vers ${place.name}...')),
                    );
                  },
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text('Y aller'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
