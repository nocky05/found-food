import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:found_food/features/posts/presentation/providers/post_provider.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_typography.dart';

class CreatePostScreen extends StatefulWidget {
  final String? preSelectedPlace; // Optional: If coming from AddPlaceScreen

  const CreatePostScreen({super.key, this.preSelectedPlace});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _tipsController = TextEditingController();
  
  double _rating = 0;
  String? _selectedLocation;
  
  // Mock locations for dropdown
  final List<String> _locations = [
    'Le Petit Bistro',
    'Sushi Paradise',
    'Café des Arts',
    'Burger King Place',
    'Parc Central',
  ];

  final List<String> _mediaPaths = [];
  bool _isVideo = false; // Just a flag for simulation

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedPlace != null) {
      _selectedLocation = widget.preSelectedPlace;
      if (!_locations.contains(widget.preSelectedPlace)) {
        _locations.add(widget.preSelectedPlace!);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  void _pickMedia(bool video) async {
    // Simulate picker
    if (video) {
      if (_mediaPaths.isNotEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une seule vidéo autorisée (max 1 min).')));
         return;
      }
      setState(() {
        _isVideo = true;
        _mediaPaths.add('assets/mock_video.mp4');
      });
    } else {
      if (_isVideo) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de mélanger photo et vidéo.')));
         return;
      }
      if (_mediaPaths.length >= 10) return;
      
      setState(() {
         _mediaPaths.add('assets/mock_photo_${_mediaPaths.length}.jpg');
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedLocation == null || _descriptionController.text.isEmpty || _mediaPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un lieu, ajouter une description et au moins un média.')),
      );
      return;
    }
    
    final postProvider = context.read<PostProvider>();
    
    // Pour la démo, on simule un placeId si on n'en a pas un vrai
    String placeId = "id_demo_place"; 
    
    final success = await postProvider.createPost(
      placeId: placeId,
      content: _descriptionController.text.trim(),
      budgetSpent: double.tryParse(_budgetController.text) ?? 0,
      tripCost: 0, // Optionnel ici
      tripDuration: 0, // Optionnel ici
      transportMode: 'N/A',
      mediaPaths: _mediaPaths,
    );
    
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avis publié avec succès !'),
            backgroundColor: AppColors.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postProvider.error ?? 'Erreur lors de la publication'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nouvel Avis',
          style: AppTypography.h3.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Publier',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Selection Area
            Text(
              'Photos (max 10) ou Vidéo (max 1 min)',
              style: AppTypography.h3.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add Photo Button
                  _buildMediaButton(
                    icon: Icons.add_a_photo,
                    label: 'Photo',
                    onTap: () => _pickMedia(false),
                  ),
                  const SizedBox(width: 12),
                  // Add Video Button
                  _buildMediaButton(
                    icon: Icons.missed_video_call, // best approximation for add video
                    label: 'Vidéo',
                    onTap: () => _pickMedia(true),
                  ),
                  const SizedBox(width: 24),
                  
                  // Media List
                  ..._mediaPaths.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.5)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Icon(
                              _isVideo ? Icons.videocam : Icons.image, 
                              size: 40, color: Colors.white
                            ),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: InkWell(
                              onTap: () => setState(() => _mediaPaths.removeAt(entry.key)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location
            _buildSectionTitle('Lieu concerné'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  hint: Text(
                    'Sélectionnez un lieu',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  items: _locations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLocation = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            _buildSectionTitle('Votre expérience'),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Racontez-nous... (ambiance, service, saveurs)',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Additional Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Budget Perso'),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Ex: 5000 FCFA',
                          filled: true,
                          fillColor: const Color(0xFFF5F6FA),
                           border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Conseils / Astuces (Optionnel)'),
            TextField(
              controller: _tipsController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ex: Venez tôt pour avoir une table en terrasse !',
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: AppTypography.h3.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildMediaButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDFE6E9)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
