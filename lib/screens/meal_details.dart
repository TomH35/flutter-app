import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../widgets/meal_item.dart' show enumLabel;

// StatefulWidget: hviezdička sa musí prekresliť hneď po kliknutí.
// Otvorená obrazovka sa totiž neprebuduje, keď setState() zavolá TabsScreen.
class MealDetailsScreen extends StatefulWidget {
  final Meal meal;
  final bool isFavorite;
  final void Function(Meal meal) onToggleFavorite;

  const MealDetailsScreen({
    super.key,
    required this.meal,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onToggleFavorite(widget.meal); // uloženie stavu v TabsScreen
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    final bodyStyle =
        theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onSurface);

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.title),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _toggleFavorite,
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Hero(
              tag: meal.id,
              child: Image.network(
                meal.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const Icon(Icons.restaurant, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Základné informácie
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text('${meal.duration} min'),
                ),
                Chip(
                  avatar: const Icon(Icons.work, size: 18),
                  label: Text(enumLabel(meal.complexity)),
                ),
                Chip(
                  avatar: const Icon(Icons.attach_money, size: 18),
                  label: Text(enumLabel(meal.affordability)),
                ),
                if (meal.isGlutenFree) const Chip(label: Text('Gluten-free')),
                if (meal.isLactoseFree) const Chip(label: Text('Lactose-free')),
                if (meal.isVegetarian) const Chip(label: Text('Vegetarian')),
                if (meal.isVegan) const Chip(label: Text('Vegan')),
              ],
            ),
            const SizedBox(height: 16),

            // Ingrediencie
            Text('Ingredients', style: headingStyle),
            const SizedBox(height: 12),
            for (final ingredient in meal.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: Text(ingredient,
                    textAlign: TextAlign.center, style: bodyStyle),
              ),
            const SizedBox(height: 24),

            // Postup
            Text('Steps', style: headingStyle),
            const SizedBox(height: 12),
            for (var i = 0; i < meal.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(meal.steps[i], style: bodyStyle)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
