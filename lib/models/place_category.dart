import 'package:flutter/material.dart';

enum PlaceCategory {
  nature('nature', 'Príroda', Icons.forest, Colors.green),
  city('city', 'Mesto', Icons.location_city, Colors.blue),
  food('food', 'Jedlo', Icons.restaurant, Colors.orange),
  culture('culture', 'Kultúra', Icons.museum, Colors.purple),
  other('other', 'Iné', Icons.place, Colors.blueGrey);

  const PlaceCategory(this.value, this.label, this.icon, this.color);

  /// Value stored in the database / sent to the API.
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static PlaceCategory fromValue(String? value) {
    return PlaceCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => PlaceCategory.other,
    );
  }
}
