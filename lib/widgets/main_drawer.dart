import 'package:flutter/material.dart';

// Postranné menu – iba posiela signál do TabsScreen, logiku nerieši.
class MainDrawer extends StatelessWidget {
  final void Function(String identifier) onSelectScreen;

  const MainDrawer({super.key, required this.onSelectScreen});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final itemStyle = Theme.of(context)
        .textTheme
        .titleSmall!
        .copyWith(color: colors.onSurface, fontSize: 24);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primaryContainer,
                  colors.primaryContainer.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.fastfood, size: 48, color: colors.primary),
                const SizedBox(width: 18),
                Flexible(
                  child: Text(
                    'Cooking Up!',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.restaurant, size: 26, color: colors.onSurface),
            title: Text('Meals', style: itemStyle),
            onTap: () => onSelectScreen('meals'),
          ),
          ListTile(
            leading: Icon(Icons.settings, size: 26, color: colors.onSurface),
            title: Text('Filters', style: itemStyle),
            onTap: () => onSelectScreen('filters'),
          ),
        ],
      ),
    );
  }
}
