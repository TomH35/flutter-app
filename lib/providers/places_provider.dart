import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../models/place_category.dart';
import '../services/api_service.dart';

class PlacesProvider extends ChangeNotifier {
  PlacesProvider({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  PlaceCategory? _categoryFilter;
  bool _favoritesOnly = false;
  String _search = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  PlaceCategory? get categoryFilter => _categoryFilter;
  bool get favoritesOnly => _favoritesOnly;
  bool get hasActiveFilter =>
      _categoryFilter != null || _favoritesOnly || _search.isNotEmpty;

  List<Place> get allPlaces => List.unmodifiable(_places);

  /// Places after applying the category, favorite and search filters.
  List<Place> get places {
    final query = _search.toLowerCase();
    return _places.where((place) {
      if (_categoryFilter != null && place.category != _categoryFilter) {
        return false;
      }
      if (_favoritesOnly && !place.isFavorite) return false;
      if (query.isNotEmpty &&
          !place.name.toLowerCase().contains(query) &&
          !place.description.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  int get favoriteCount => _places.where((place) => place.isFavorite).length;

  double get averageRating {
    if (_places.isEmpty) return 0;
    return _places.fold<int>(0, (sum, place) => sum + place.rating) /
        _places.length;
  }

  Map<PlaceCategory, int> get countByCategory {
    return {
      for (final category in PlaceCategory.values)
        category: _places.where((place) => place.category == category).length,
    };
  }

  Place? findById(int id) {
    for (final place in _places) {
      if (place.id == id) return place;
    }
    return null;
  }

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _places = await _api.fetchPlaces();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates or updates [place]. When [photoBytes] are given, the photo is
  /// uploaded first and attached to the place.
  Future<Place> savePlace(
    Place place, {
    Uint8List? photoBytes,
    String? photoName,
  }) async {
    if (photoBytes != null) {
      final photo = await _api.uploadPhoto(
        photoBytes,
        photoName ?? 'photo.jpg',
      );
      place = place.copyWith(photo: photo);
    }

    final saved = place.id == null
        ? await _api.createPlace(place)
        : await _api.updatePlace(place);

    final index = _places.indexWhere((p) => p.id == saved.id);
    if (index == -1) {
      _places.insert(0, saved);
    } else {
      _places[index] = saved;
    }
    notifyListeners();
    return saved;
  }

  Future<void> deletePlace(int id) async {
    await _api.deletePlace(id);
    _places.removeWhere((place) => place.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    final updated = await _api.toggleFavorite(id);
    final index = _places.indexWhere((place) => place.id == id);
    if (index != -1) {
      _places[index] = updated;
      notifyListeners();
    }
  }

  void setCategoryFilter(PlaceCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _favoritesOnly = !_favoritesOnly;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value.trim();
    notifyListeners();
  }
}
