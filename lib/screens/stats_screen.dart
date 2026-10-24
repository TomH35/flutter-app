import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place_category.dart';
import '../providers/places_provider.dart';
import '../widgets/stat_tile.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();
    final total = provider.allPlaces.length;
    final counts = provider.countByCategory;

    return Scaffold(
      appBar: AppBar(title: const Text('Štatistiky')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.place_outlined,
                      value: '$total',
                      label: 'Miest',
                    ),
                  ),
                  Expanded(
                    child: StatTile(
                      icon: Icons.favorite_border,
                      value: '${provider.favoriteCount}',
                      label: 'Obľúbených',
                    ),
                  ),
                  Expanded(
                    child: StatTile(
                      icon: Icons.star_outline_rounded,
                      value: provider.averageRating.toStringAsFixed(1),
                      label: 'Priemerné hodnotenie',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Podľa kategórie',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Ťuknutím zobrazíte miesta z kategórie.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final category in PlaceCategory.values)
                _CategoryBar(
                  category: category,
                  count: counts[category]!,
                  total: total,
                  onTap: () {
                    provider.setCategoryFilter(category);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.count,
    required this.total,
    required this.onTap,
  });

  final PlaceCategory category;
  final int count;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 12),
            SizedBox(width: 72, child: Text(category.label)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : count / total,
                  minHeight: 12,
                  color: category.color,
                  backgroundColor: category.color.withValues(alpha: 0.15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 28,
              child: Text('$count', textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
