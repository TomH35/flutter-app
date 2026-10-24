import 'place_category.dart';

class Place {
  const Place({
    this.id,
    required this.name,
    this.description = '',
    this.category = PlaceCategory.other,
    this.rating = 3,
    this.latitude,
    this.longitude,
    this.photo,
    this.isFavorite = false,
    this.visitedAt,
    this.createdAt,
  });

  /// Null until the place is saved on the server.
  final int? id;
  final String name;
  final String description;
  final PlaceCategory category;
  final int rating;
  final double? latitude;
  final double? longitude;

  /// Path relative to the backend folder, e.g. `uploads/abc.jpg`.
  final String? photo;
  final bool isFavorite;
  final DateTime? visitedAt;
  final DateTime? createdAt;

  bool get hasLocation => latitude != null && longitude != null;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: PlaceCategory.fromValue(json['category'] as String?),
      rating: json['rating'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photo: json['photo'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      visitedAt: DateTime.tryParse(json['visited_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category.value,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'photo': photo,
      'is_favorite': isFavorite,
      'visited_at': visitedAt?.toIso8601String().substring(0, 10),
    };
  }

  Place copyWith({String? photo, bool? isFavorite}) {
    return Place(
      id: id,
      name: name,
      description: description,
      category: category,
      rating: rating,
      latitude: latitude,
      longitude: longitude,
      photo: photo ?? this.photo,
      isFavorite: isFavorite ?? this.isFavorite,
      visitedAt: visitedAt,
      createdAt: createdAt,
    );
  }
}
