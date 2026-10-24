import 'package:flutter/material.dart';

import '../models/place.dart';
import '../utils/formatters.dart';
import 'place_photo.dart';
import 'rating_stars.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Place place;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: Hero(
                tag: 'place-photo-${place.id}',
                child: PlacePhoto(photo: place.photo, category: place.category),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      place.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          place.category.icon,
                          size: 16,
                          color: place.category.color,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            place.visitedAt == null
                                ? place.category.label
                                : '${place.category.label} · ${formatDate(place.visitedAt!)}',
                            style: textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RatingStars(rating: place.rating, size: 16),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: place.isFavorite
                  ? 'Odobrať z obľúbených'
                  : 'Pridať do obľúbených',
              onPressed: onFavoriteToggle,
              icon: Icon(
                place.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: place.isFavorite ? Colors.redAccent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
