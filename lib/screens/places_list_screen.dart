import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/places_provider.dart';
import '../services/api_service.dart';
import '../utils/snackbars.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/message_view.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';
import 'place_form_screen.dart';
import 'stats_screen.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  static const _cardHeight = 112.0;
  static const _gridBreakpoint = 700.0;

  Future<void> _openForm(BuildContext context) async {
    final created = await Navigator.push<Place>(
      context,
      MaterialPageRoute(builder: (_) => const PlaceFormScreen()),
    );
    if (created != null && context.mounted) {
      showMessage(context, 'Miesto „${created.name}“ bolo pridané.');
    }
  }

  Future<void> _openDetail(BuildContext context, Place place) async {
    // The detail screen returns the name of the place when it was deleted.
    final deletedName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id!)),
    );
    if (deletedName != null && context.mounted) {
      showMessage(context, 'Miesto „$deletedName“ bolo odstránené.');
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
    final provider = context.watch<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje miesta'),
        actions: [
          IconButton(
            tooltip: 'Len obľúbené',
            isSelected: provider.favoritesOnly,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: provider.toggleFavoritesOnly,
          ),
          IconButton(
            tooltip: 'Obnoviť',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : provider.loadPlaces,
          ),
          IconButton(
            tooltip: 'Štatistiky',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Hľadať miesto…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: provider.setSearch,
            ),
          ),
          CategoryFilterBar(
            selected: provider.categoryFilter,
            onSelected: provider.setCategoryFilter,
          ),
          if (provider.isLoading && provider.allPlaces.isNotEmpty)
            const LinearProgressIndicator(),
          if (provider.error != null && provider.allPlaces.isNotEmpty)
            _ErrorStrip(message: provider.error!),
          Expanded(child: _buildContent(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Pridať miesto'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlacesProvider provider) {
    if (provider.isLoading && provider.allPlaces.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.allPlaces.isEmpty) {
      return MessageView(
        icon: Icons.cloud_off,
        title: 'Miesta sa nepodarilo načítať',
        message: provider.error,
        actionLabel: 'Skúsiť znova',
        onAction: provider.loadPlaces,
      );
    }

    final places = provider.places;
    if (places.isEmpty) {
      return provider.hasActiveFilter
          ? const MessageView(
              icon: Icons.filter_alt_off_outlined,
              title: 'Žiadne miesto nezodpovedá filtru',
            )
          : const MessageView(
              icon: Icons.explore_outlined,
              title: 'Zatiaľ nemáte žiadne miesta',
              message: 'Pridajte prvé miesto tlačidlom nižšie.',
            );
    }

    Widget buildCard(int index) {
      final place = places[index];
      return PlaceCard(
        place: place,
        onTap: () => _openDetail(context, place),
        onFavoriteToggle: () => _toggleFavorite(context, place),
      );
    }

    const padding = EdgeInsets.fromLTRB(12, 4, 12, 88);

    return RefreshIndicator(
      onRefresh: provider.loadPlaces,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Narrow screens (phones): single column list.
          if (constraints.maxWidth < _gridBreakpoint) {
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              itemCount: places.length,
              itemBuilder: (context, index) =>
                  SizedBox(height: _cardHeight, child: buildCard(index)),
            );
          }

          // Wide screens (tablet, desktop, web): grid with as many columns as fit.
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: _cardHeight,
            ),
            itemCount: places.length,
            itemBuilder: (context, index) => buildCard(index),
          );
        },
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colors.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
