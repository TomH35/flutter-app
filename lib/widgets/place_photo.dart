import 'package:flutter/material.dart';

import '../models/place_category.dart';
import '../services/api_service.dart';

/// Photo of a place loaded from the backend, or a category icon placeholder.
class PlacePhoto extends StatelessWidget {
  const PlacePhoto({
    super.key,
    required this.photo,
    required this.category,
    this.iconSize = 32,
  });

  final String? photo;
  final PlaceCategory category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (photo == null) return _placeholder();

    return Image.network(
      ApiService.photoUrl(photo!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: category.color.withValues(alpha: 0.12),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: category.color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(category.icon, color: category.color, size: iconSize),
    );
  }
}
