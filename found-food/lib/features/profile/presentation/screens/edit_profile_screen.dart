import 'dart:io';
import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/profile/domain/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().userProfile;
    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<ProfileProvider>();
      String? avatarUrl = provider.userProfile?.avatarUrl;

      // 1. Upload nouvelle image si sélectionnée
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final url = await provider.uploadAvatar(bytes);
        if (url != null) {
          avatarUrl = url;
        }
      }

      // 2. Créer l'objet profil mis à jour
      // On garde l'ID existant
      final currentProfile = provider.userProfile;
      if (currentProfile == null) return;

      final updatedProfile = Profile(
        id: currentProfile.id, // Garder l'ID
        username: _usernameController.text,
        fullName: _fullNameController.text,
        bio: _bioController.text,
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      // 3. Sauvegarder
      final success = await provider.updateProfile(updatedProfile);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès !'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalAvatarUrl = context.select<ProfileProvider, String?>((p) => p.userProfile?.avatarUrl);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Enregistrer',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            // Avatar Change
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.lightPeach,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: _imageFile != null
                            ? NetworkImage(_imageFile!.path) // En web, path est une URL blob
                            : (originalAvatarUrl != null && originalAvatarUrl.isNotEmpty
                                ? NetworkImage(originalAvatarUrl)
                                : null),
                        child: (_imageFile == null && (originalAvatarUrl == null || originalAvatarUrl.isEmpty))
                            ? const Icon(Icons.person, size: 50, color: AppColors.primaryOrange)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Fields
            _buildEditField('Nom complet', _fullNameController),
            const SizedBox(height: 20),
            _buildEditField('Nom d\'utilisateur', _usernameController),
            const SizedBox(height: 20),
            _buildEditField('Bio', _bioController, maxLines: 3),
            
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Changer les paramètres personnels',
                style: TextStyle(color: AppColors.primaryOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryOrange),
            ),
          ),
        ),
      ],
    );
  }
}
