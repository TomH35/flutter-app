// Dátový model pre odpoveď USGS Earthquake API (formát GeoJSON).
// Štruktúra: EarthquakeModel → features → properties / geometry.

class EarthquakeModel {
  String? type;
  Metadata? metadata;
  List<Features>? features;
  List<num>? bbox;

  EarthquakeModel({this.type, this.metadata, this.features, this.bbox});

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) {
    return EarthquakeModel(
      type: json['type'] as String?,
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => Features.fromJson(e as Map<String, dynamic>))
          .toList(),
      bbox: (json['bbox'] as List<dynamic>?)?.map((e) => e as num).toList(),
    );
  }
}

class Metadata {
  num? generated;
  String? url;
  String? title;
  num? status;
  String? api;
  num? count;

  Metadata({
    this.generated,
    this.url,
    this.title,
    this.status,
    this.api,
    this.count,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      generated: json['generated'] as num?,
      url: json['url'] as String?,
      title: json['title'] as String?,
      status: json['status'] as num?,
      api: json['api'] as String?,
      count: json['count'] as num?,
    );
  }
}

class Features {
  String? type;
  Properties? properties;
  Geometry? geometry;
  String? id;

  Features({this.type, this.properties, this.geometry, this.id});

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      type: json['type'] as String?,
      properties: json['properties'] == null
          ? null
          : Properties.fromJson(json['properties'] as Map<String, dynamic>),
      geometry: json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      id: json['id'] as String?,
    );
  }
}

class Properties {
  num? mag; // magnitúda
  String? place; // miesto výskytu
  num? time; // čas výskytu (ms od 1. 1. 1970)
  num? updated; // čas poslednej aktualizácie
  String? url;
  String? alert; // green / yellow / orange / red (môže byť null)
  num? tsunami;
  String? type;
  String? title;

  Properties({
    this.mag,
    this.place,
    this.time,
    this.updated,
    this.url,
    this.alert,
    this.tsunami,
    this.type,
    this.title,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      mag: json['mag'] as num?,
      place: json['place'] as String?,
      time: json['time'] as num?,
      updated: json['updated'] as num?,
      url: json['url'] as String?,
      alert: json['alert'] as String?,
      tsunami: json['tsunami'] as num?,
      type: json['type'] as String?,
      title: json['title'] as String?,
    );
  }
}

class Geometry {
  String? type;
  List<num>? coordinates; // [longitude, latitude, hĺbka]

  Geometry({this.type, this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'] as String?,
      coordinates:
          (json['coordinates'] as List<dynamic>?)?.map((e) => e as num).toList(),
    );
  }
}
