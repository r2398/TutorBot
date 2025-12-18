// Image upload widget

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUpload extends StatelessWidget {
  final Function(String) onImageSelected;

  const ImageUpload({
    super.key,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    ImageSource? source;
    
    if (kIsWeb) {
      // On web, only gallery is available
      source = ImageSource.gallery;
    } else {
      // On mobile, show both options
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );
    }

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        // In a real app, upload to server and get URL
        onImageSelected(image.path);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.image),
      tooltip: kIsWeb ? 'Upload image from computer' : 'Upload image',
      onPressed: () => _pickImage(context),
    );
  }
}