import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/search/presentation/providers/search_provider.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> _categories = [
    'Restaurants', 'Cafés', 'Plages', 'Parcs', 'Piscines', 'Îles', 'Espaces Publics'
  ];

  final List<IconData> _categoryIcons = [
    Icons.restaurant, Icons.coffee, Icons.beach_access, Icons.park, Icons.pool, Icons.landscape, Icons.location_city
  ];

  String _selectedBudget = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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

                  if (provider.results.isNotEmpty) {
                    return _buildSearchResults(provider.results);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Budget'),
                        const SizedBox(height: AppDimensions.spaceSM),
                        _buildBudgetFilters(),
                        const SizedBox(height: AppDimensions.spaceLG),
                        _buildSectionTitle('Catégories'),
                        const SizedBox(height: AppDimensions.spaceSM),
                        _buildCategoriesGrid(),
                        const SizedBox(height: AppDimensions.spaceLG),
                        _buildSectionTitle('Recherches récentes'),
                        _buildRecentSearches(),
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
        color: Colors.white,
        boxShadow: [
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
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: TextField(
              onChanged: (value) => context.read<SearchProvider>().onQueryChanged(value),
              decoration: const InputDecoration(
                hintText: 'Où voulez-vous manger ?',
                hintStyle: TextStyle(color: AppColors.textLight),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.primaryOrange),
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
                        place.category ?? 'Restaurant',
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      place.budgetRange ?? 'FCFA',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers les détails ici
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBudgetFilters() {
    return Row(
      children: ['FCFA', 'FCFA FCFA', 'FCFA FCFA FCFA'].map((budget) {
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              side: BorderSide(
                color: isSelected ? AppColors.primaryOrange : AppColors.borderColor,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
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
                      color: AppColors.textPrimary,
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

  Widget _buildRecentSearches() {
    final recent = ['Pizza', 'Sushi', 'Bistro', 'Plage de Ngor'];
    return Column(
      children: recent.map((item) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.history, color: AppColors.textLight, size: 20),
        title: Text(item, style: AppTypography.bodyMedium),
        trailing: const Icon(Icons.north_west, color: AppColors.textLight, size: 16),
        onTap: () {},
      )).toList(),
    );
  }
}
