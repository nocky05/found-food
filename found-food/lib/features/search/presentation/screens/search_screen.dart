import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/search/presentation/providers/search_provider.dart';
import 'package:found_food/features/places/domain/repositories/place_repository.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'Restaurants', 'Cafés', 'Plages', 'Parcs', 'Piscines', 'Îles', 'Espaces Publics'
  ];

  final List<IconData> _categoryIcons = [
    Icons.restaurant, Icons.coffee, Icons.beach_access, Icons.park, Icons.pool, Icons.landscape, Icons.location_city
  ];

  String _selectedBudget = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Si une recherche est active et (a des résultats OU n'a pas de résultats mais ce n'est pas vide)
                  // On veut afficher la liste ou "Rien trouvé"
                  if (_searchController.text.isNotEmpty) {
                     if (provider.results.isNotEmpty) {
                       return _buildSearchResults(provider.results);
                     } else {
                       return Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             const Icon(Icons.search_off, size: 64, color: Colors.grey),
                             const SizedBox(height: 16),
                             Text(
                               'Aucun lieu trouvé pour "${_searchController.text}"', 
                               style: AppTypography.bodyMedium.copyWith(
                                 color: Theme.of(context).textTheme.bodyLarge?.color
                               )
                             ),
                           ],
                         ),
                       );
                     }
                  }

                  // Default state: Suggestions & Categories
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Explorer par Budget', 'Sélectionnez une fourchette de prix'),
                        const SizedBox(height: AppDimensions.spaceSM),
                        _buildBudgetFilters(),
                        const SizedBox(height: AppDimensions.spaceLG),
                        _buildSectionTitle('Catégories Populaires', 'Suggestions de lieux à visiter'),
                        const SizedBox(height: AppDimensions.spaceSM),
                        _buildCategoriesGrid(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: Theme.of(context).brightness == Brightness.dark 
            ? null 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => context.read<SearchProvider>().onQueryChanged(value),
              decoration: InputDecoration(
                hintText: 'Rechercher un lieu, resto...',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white38 
                      : AppColors.textLight
                ),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: AppColors.primaryOrange),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          context.read<SearchProvider>().onQueryChanged('');
                        });
                      },
                    )
                  : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final place = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppDimensions.paddingSM),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              child: Container(
                width: 60,
                height: 60,
                color: AppColors.surfaceColor,
                child: const Icon(Icons.restaurant, color: AppColors.primaryOrange),
              ),
            ),
            title: Text(place.name, style: AppTypography.h4),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.address, style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        place.category ?? 'Lieu',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // Fetch posts for this place
              try {
                final posts = await PlaceRepository().getPostsForPlace(place.id);
                
                if (!context.mounted) return;
                
                if (posts.isEmpty) {
                  // No posts yet for this place
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Aucun post pour "${place.name}" pour le moment'),
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {},
                      ),
                    ),
                  );
                } else {
                  // Navigate to details with the first post
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsScreen(post: posts.first),
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors du chargement du lieu')),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white38 
                : AppColors.textLight
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetFilters() {
    return Row(
      children: ['< 5k', '5k - 15k', '> 15k'].map((budget) {
        final isSelected = _selectedBudget == budget;
        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spaceSM),
          child: FilterChip(
            label: Text(budget),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedBudget = selected ? budget : '';
              });
            },
            selectedColor: AppColors.primaryOrange.withOpacity(0.2),
            checkmarkColor: AppColors.primaryOrange,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primaryOrange : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              side: BorderSide(
                color: isSelected ? AppColors.primaryOrange : Theme.of(context).dividerColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spaceMD,
        mainAxisSpacing: AppDimensions.spaceMD,
        childAspectRatio: 2.5,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: Theme.of(context).brightness == Brightness.dark 
                ? null 
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_categoryIcons[index], color: AppColors.primaryOrange, size: 20),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: Text(
                    _categories[index],
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
