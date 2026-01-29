import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:found_food/features/posts/presentation/providers/post_provider.dart';
import 'package:found_food/features/places/domain/repositories/place_repository.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _searchController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tripDescController = TextEditingController();
  final _tripCostController = TextEditingController();
  final _tripDurationController = TextEditingController();
  final _transportModeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController(); 

  bool _isChecking = false; 
  bool _placeFound = false; 
  bool _showForm = false; 

  String? _selectedCategory;
  final List<String> _categories = [
    'Restaurant', 'Parc', 'Plage', 'Piscine', 'Île', 'Espace public', 'Autre'
  ];
  String? _selectedBudget;
  final List<String> _budgets = ['< 5.000', '5.000 - 15.000', '> 15.000'];

  final ImagePicker _picker = ImagePicker();
  XFile? _menuPhoto; 
  final List<XFile> _experienceMedia = []; 

  // Search Results
  List<Place> _searchResults = [];
  bool _showSearchResults = false;
  Place? _selectedPlace; 

  @override
  void dispose() {
    _searchController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _tripDescController.dispose();
    _tripCostController.dispose();
    _tripDurationController.dispose();
    _transportModeController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _checkPlaceExistence() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() { 
      _isChecking = true; 
      _showForm = false; 
      _showSearchResults = false; 
      _selectedPlace = null;
      _placeFound = false;
    });

    try {
      final results = await PlaceRepository().searchPlaces(query);
      
      setState(() {
        _isChecking = false;
        _searchResults = results;
        if (results.isEmpty) {
          // Si rien trouvé, on propose de créer
          _showForm = true;
          _placeFound = false;
        } else {
          // Si trouvé, on affiche la liste
          _showSearchResults = true;
        }
      });
    } catch (e) {
      print("Erreur recherche lieu: $e");
      setState(() {
         _isChecking = false;
         _showForm = true; // Fallback création
         _placeFound = false;
      });
    }
  }

  void _selectPlace(Place place) {
    setState(() {
      _selectedPlace = place;
      _searchController.text = place.name;
      _placeFound = true;
      _showSearchResults = false;
      _showForm = true;
    });
  }

  void _createNewPlace() {
    setState(() {
      _selectedPlace = null;
      _placeFound = false;
      _showSearchResults = false;
      _showForm = true;
    });
  }

  Future<void> _pickMenuPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() { _menuPhoto = image; });
    }
  }

  Future<void> _pickExperienceMedia() async {
    if (_experienceMedia.length >= 10) return;
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _experienceMedia.addAll(images.take(10 - _experienceMedia.length));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Nouvelle Découverte', style: AppTypography.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchSection(),
            
            if (_showSearchResults)
              _buildSearchResults(),

            if (_showForm) ...[
              if (!_placeFound) _buildNewPlaceForm(),
              if (_placeFound) _buildSelectedPlaceInfo(),
              
              const SizedBox(height: 24),
              _buildExperienceSection(),
              const SizedBox(height: 32),
              
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ..._searchResults.map((place) => ListTile(
            title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(place.address),
            leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
            onTap: () => _selectPlace(place),
          )).toList(),
          const Divider(),
          ListTile(
            title: Text('Ce n\'est pas dans la liste ?', style: TextStyle(color: AppColors.primaryOrange)),
            subtitle: const Text('Ajouter ce nouveau lieu'),
            leading: const Icon(Icons.add, color: AppColors.primaryOrange),
            onTap: _createNewPlace,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlaceInfo() {
    if (_selectedPlace == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPlace!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(_selectedPlace!.address),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _placeFound = false;
                _showForm = false;
                _selectedPlace = null;
                _searchController.clear();
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _checkPlaceExistence(),
        decoration: InputDecoration(
          hintText: 'Quel lieu avez-vous visité ?',
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryOrange),
          suffixIcon: _isChecking 
            ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _checkPlaceExistence),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildNewPlaceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nouveau Lieu détecté', Icons.add_location_alt),
        _buildCard(
          child: Column(
            children: [
              _buildDropdown(hint: 'Type de lieu', value: _selectedCategory, items: _categories, onChanged: (v) => setState(() => _selectedCategory = v)),
              const Divider(),
              _buildInput(_addressController, 'Adresse complète', Icons.map),
              _buildInput(_phoneController, 'Téléphone (Optionnel)', Icons.phone, inputType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildMenuPhotoSelector(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Accessibilité & Trajet', Icons.directions_bus),
        _buildCard(
          child: Column(
            children: [
              _buildInput(_tripDescController, 'Description du trajet', Icons.directions),
              Row(
                children: [
                  Expanded(child: _buildInput(_tripCostController, 'Coût (FCFA)', Icons.money, inputType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(_tripDurationController, 'Durée (min)', Icons.timer, inputType: TextInputType.number)),
                ],
              ),
              _buildInput(_transportModeController, 'Moyen de transport', Icons.commute),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuPhotoSelector() {
    return InkWell(
      onTap: _pickMenuPhoto,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondaryYellow.withOpacity(0.3)),
        ),
        child: _menuPhoto == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, color: AppColors.primaryOrange),
            Text('Photo du menu', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
          ],
        ) : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(_menuPhoto!.path, fit: BoxFit.cover), // pickImage returns local path even on Web (blob/blob)
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Votre Expérience', Icons.star_rate),
        _buildCard(
          child: Column(
            children: [
              _buildExperienceMediaList(),
              const SizedBox(height: 20),
              _buildInput(_descriptionController, 'Racontez-nous...', Icons.edit_note, maxLines: 4),
              const SizedBox(height: 12),
              _buildInput(_budgetController, 'Combien avez-vous dépensé ? (FCFA)', Icons.account_balance_wallet, inputType: TextInputType.number),
              const SizedBox(height: 20),
              const Text('Budget Moyen sur place (FCFA)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildBudgetSelector(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceMediaList() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          InkWell(
            onTap: _pickExperienceMedia,
            child: Container(
              width: 90, margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: const Icon(Icons.add_a_photo, color: Colors.grey),
            ),
          ),
          ..._experienceMedia.map((xfile) => Container(
            width: 90, margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(xfile.path, fit: BoxFit.cover)),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Row(
      children: _budgets.map((b) {
        final isSelected = _selectedBudget == b;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedBudget = b),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: isSelected ? AppColors.primaryOrange : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Text(b, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: postProvider.isLoading ? null : _handlePublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: postProvider.isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('Publier maintenant', style: AppTypography.h3.copyWith(color: Colors.white)),
          ),
        );
      },
    );
  }

  Future<void> _handlePublish() async {
    final postProvider = context.read<PostProvider>();
    try {
      String? menuUrl;
      if (_menuPhoto != null) {
        menuUrl = await PlaceRepository().uploadPlaceImage(_menuPhoto!, 'menus');
      }

      String placeId;
      if (_placeFound && _selectedPlace != null) {
        placeId = _selectedPlace!.id;
      } else {
        placeId = await PlaceRepository().createPlace(
          name: _searchController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          category: _selectedCategory,
          budgetRange: _selectedBudget,
          menuUrl: menuUrl,
        );
      }

      final success = await postProvider.createPost(
        placeId: placeId,
        content: _descriptionController.text.trim(),
        budgetSpent: _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null,
        tripCost: _tripCostController.text.isNotEmpty ? double.tryParse(_tripCostController.text) : null,
        tripDuration: _tripDurationController.text.isNotEmpty ? int.tryParse(_tripDurationController.text) : null,
        transportMode: _transportModeController.text.isNotEmpty ? _transportModeController.text : null,
        mediaFiles: _experienceMedia,
      );

      if (mounted && success) {
        // Sync Profile Data immediately after post creation
        context.read<ProfileProvider>().fetchProfileData();
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publication réussie !'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 20),
          const SizedBox(width: 8),
          Text(title, style: AppTypography.h3),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(border: InputBorder.none, prefixIcon: const Icon(Icons.category, color: Colors.grey)),
      hint: Text(hint),
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
