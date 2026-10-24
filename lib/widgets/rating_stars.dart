import 'package:flutter/material.dart';

/// Shows a 1–5 star rating. When [onChanged] is set, stars can be tapped.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 20,
  });

  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var value = 1; value <= 5; value++) _buildStar(value)],
    );
  }

  Widget _buildStar(int value) {
    final icon = Icon(
      value <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
      color: Colors.amber,
      size: size,
    );

    if (onChanged == null) return icon;

    return IconButton(
      icon: icon,
      tooltip: '$value / 5',
      visualDensity: VisualDensity.compact,
      onPressed: () => onChanged!(value),
    );
  }
}
