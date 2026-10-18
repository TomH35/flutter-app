import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../widgets/meal_item.dart';
import 'meal_details.dart';

class MealsScreen extends StatelessWidget {
  final String? title; // bez titulku = zobrazené v záložke (bez Scaffoldu)
  final List<Meal> meals;
  final void Function(Meal meal) onToggleFavorite;
  final bool Function(Meal meal) isFavorite;

  const MealsScreen({
    super.key,
    this.title,
    required this.meals,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  void _selectMeal(BuildContext context, Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealDetailsScreen(
          meal: meal,
          isFavorite: isFavorite(meal),
          onToggleFavorite: onToggleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    Widget content = ListView.builder(
      itemCount: meals.length,
      itemBuilder: (ctx, index) => MealItem(
        meal: meals[index],
        onSelectMeal: (meal) => _selectMeal(ctx, meal),
      ),
    );

    if (meals.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Uh oh... nothing here!',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(color: textColor),
              ),
              const SizedBox(height: 16),
              Text(
                title == null
                    ? 'Mark meals with ★ to see them here.'
                    : 'Try selecting a different category or change your filters!',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).textTheme.bodyLarge!.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      );
    }

    if (title == null) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title!)),
      body: content,
    );
  }
}
