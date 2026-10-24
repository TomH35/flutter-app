import 'package:flutter/material.dart';

import '../models/place_category.dart';

/// Horizontal list of chips. `null` in [onSelected] means "all categories".
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip(label: 'Všetky', isSelected: selected == null, value: null),
          for (final category in PlaceCategory.values)
            _chip(
              label: category.label,
              icon: category.icon,
              isSelected: selected == category,
              value: category,
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required PlaceCategory? value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        avatar: icon == null || isSelected ? null : Icon(icon, size: 18),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
      ),
    );
  }
}
