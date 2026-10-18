import 'package:flutter/material.dart';

enum Filter {
  glutenFree,
  lactoseFree,
  vegetarian,
  vegan,
}

class FiltersScreen extends StatefulWidget {
  final Map<Filter, bool> currentFilters;

  const FiltersScreen({super.key, required this.currentFilters});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  var _glutenFreeFilterSet = false;
  var _lactoseFreeFilterSet = false;
  var _vegetarianFilterSet = false;
  var _veganFilterSet = false;

  @override
  void initState() {
    super.initState();
    // načítanie aktuálne nastavených filtrov
    _glutenFreeFilterSet = widget.currentFilters[Filter.glutenFree]!;
    _lactoseFreeFilterSet = widget.currentFilters[Filter.lactoseFree]!;
    _vegetarianFilterSet = widget.currentFilters[Filter.vegetarian]!;
    _veganFilterSet = widget.currentFilters[Filter.vegan]!;
  }

  @override
  Widget build(BuildContext context) {
    // Bez drawer: – v AppBare tak zostane šípka späť.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // pri návrate odošleme nastavenia späť do TabsScreen
        Navigator.of(context).pop({
          Filter.glutenFree: _glutenFreeFilterSet,
          Filter.lactoseFree: _lactoseFreeFilterSet,
          Filter.vegetarian: _vegetarianFilterSet,
          Filter.vegan: _veganFilterSet,
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Filters')),
        body: Column(
          children: [
            _filterTile(
              title: 'Gluten-free',
              subtitle: 'Only include gluten-free meals.',
              value: _glutenFreeFilterSet,
              onChanged: (isChecked) =>
                  setState(() => _glutenFreeFilterSet = isChecked),
            ),
            _filterTile(
              title: 'Lactose-free',
              subtitle: 'Only include lactose-free meals.',
              value: _lactoseFreeFilterSet,
              onChanged: (isChecked) =>
                  setState(() => _lactoseFreeFilterSet = isChecked),
            ),
            _filterTile(
              title: 'Vegetarian',
              subtitle: 'Only include vegetarian meals.',
              value: _vegetarianFilterSet,
              onChanged: (isChecked) =>
                  setState(() => _vegetarianFilterSet = isChecked),
            ),
            _filterTile(
              title: 'Vegan',
              subtitle: 'Only include vegan meals.',
              value: _veganFilterSet,
              onChanged: (isChecked) =>
                  setState(() => _veganFilterSet = isChecked),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style:
            Theme.of(context).textTheme.titleLarge!.copyWith(color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style:
            Theme.of(context).textTheme.labelMedium!.copyWith(color: textColor),
      ),
      activeThumbColor: Theme.of(context).colorScheme.tertiary,
      contentPadding: const EdgeInsets.only(left: 34, right: 22),
    );
  }
}
