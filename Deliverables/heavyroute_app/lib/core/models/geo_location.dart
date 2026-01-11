class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({required this.latitude, required this.longitude});

  String toMapboxString() => "$longitude,$latitude";

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}