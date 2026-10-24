import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/place_category.dart';
import 'place_photo.dart';

/// Preview of the place photo with buttons to change or remove it.
/// [photoBytes] (a newly picked image) takes precedence over [photo] (already uploaded).
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.category,
    required this.photoBytes,
    required this.photo,
    required this.onPickFromGallery,
    required this.onRemove,
  });

  final PlaceCategory category;
  final Uint8List? photoBytes;
  final String? photo;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null || photo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: photoBytes != null
                ? Image.memory(photoBytes!, fit: BoxFit.cover)
                : PlacePhoto(photo: photo, category: category, iconSize: 56),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onPickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galéria'),
            ),
            if (hasPhoto)
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Odstrániť fotku'),
              ),
          ],
        ),
      ],
    );
  }
}
