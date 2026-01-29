import 'package:flutter/foundation.dart';
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:found_food/features/stories/presentation/providers/story_provider.dart';
import 'package:found_food/core/theme/app_colors.dart';

class StoryCreatorScreen extends StatefulWidget {
  const StoryCreatorScreen({super.key});

  @override
  State<StoryCreatorScreen> createState() => _StoryCreatorScreenState();
}

class _StoryCreatorScreenState extends State<StoryCreatorScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _uploadStory() async {
    if (_imageFile == null) return;
    
    setState(() {
      _isUploading = true;
    });

    try {
      await context.read<StoryProvider>().addStory(_imageFile!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story créée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_imageFile != null && !_isUploading)
            TextButton(
              onPressed: _uploadStory,
              child: const Text('Partager', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
            ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: _imageFile == null
            ? const CircularProgressIndicator()
            : kIsWeb 
                ? Image.network(_imageFile!.path)
                : Image.file(File(_imageFile!.path)),
      ),
    );
  }
}
