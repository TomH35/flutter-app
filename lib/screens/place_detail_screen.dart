import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/places_provider.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';
import '../utils/snackbars.dart';
import '../widgets/message_view.dart';
import '../widgets/place_photo.dart';
import '../widgets/rating_stars.dart';
import 'place_form_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final int placeId;

  Future<void> _edit(BuildContext context, Place place) async {
    final updated = await Navigator.push<Place>(
      context,
      MaterialPageRoute(builder: (_) => PlaceFormScreen(place: place)),
    );
    if (updated != null && context.mounted) {
      showMessage(context, 'Zmeny boli uložené.');
    }
  }

  Future<void> _delete(BuildContext context, Place place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odstrániť miesto?'),
        content: Text('Miesto „${place.name}“ bude natrvalo odstránené.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odstrániť'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<PlacesProvider>().deletePlace(place.id!);
      if (context.mounted) Navigator.pop(context, place.name);
    } on ApiException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }

  Future<void> _toggleFavorite(BuildContext context, Place place) async {
    try {
      await context.read<PlacesProvider>().toggleFavorite(place.id!);
    } on ApiException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds whenever this place changes in the provider (edit, favorite).
    final place = context.select<PlacesProvider, Place?>(
      (provider) => provider.findById(placeId),
    );

    if (place == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const MessageView(
          icon: Icons.location_off_outlined,
          title: 'Miesto neexistuje',
        ),
      );
    }

    final photo = Hero(
      tag: 'place-photo-${place.id}',
      child: PlacePhoto(
        photo: place.photo,
        category: place.category,
        iconSize: 72,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          IconButton(
            tooltip: place.isFavorite
                ? 'Odobrať z obľúbených'
                : 'Pridať do obľúbených',
            onPressed: () => _toggleFavorite(context, place),
            icon: Icon(
              place.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: place.isFavorite ? Colors.redAccent : null,
            ),
          ),
          IconButton(
            tooltip: 'Upraviť',
            onPressed: () => _edit(context, place),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Odstrániť',
            onPressed: () => _delete(context, place),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Wide screens: photo and details side by side.
          if (constraints.maxWidth >= 800) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(aspectRatio: 4 / 3, child: photo),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: _PlaceInfo(place: place),
                    ),
                  ),
                ],
              ),
            );
          }

          // Narrow screens: photo on top, details below.
          return ListView(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: photo),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _PlaceInfo(place: place),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaceInfo extends StatelessWidget {
  const _PlaceInfo({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(place.name, style: textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              avatar: Icon(place.category.icon, color: place.category.color),
              label: Text(place.category.label),
            ),
            RatingStars(rating: place.rating, size: 26),
          ],
        ),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.event_outlined,
          text: place.visitedAt == null
              ? 'Dátum návštevy nebol zadaný'
              : 'Navštívené ${formatDate(place.visitedAt!)}',
        ),
        if (place.hasLocation)
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: formatCoordinates(place.latitude!, place.longitude!),
            trailing: IconButton(
              tooltip: 'Kopírovať súradnice',
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: formatCoordinates(place.latitude!, place.longitude!),
                  ),
                );
                if (context.mounted) {
                  showMessage(context, 'Súradnice boli skopírované.');
                }
              },
            ),
          )
        else
          const _InfoRow(
            icon: Icons.location_off_outlined,
            text: 'Poloha nebola uložená',
          ),
        const Divider(height: 32),
        Text('Popis', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          place.description.isEmpty ? 'Bez popisu' : place.description,
          style: place.description.isEmpty
              ? textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)
              : textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.trailing});

  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          ?trailing,
        ],
      ),
    );
  }
}
