class Location { 

  double latitude;
  double longitude;
  String locationName;

  Location({
    required this.latitude,
    required this.longitude,
    required this.locationName
  });

  Location.fromJson(Map<String, Object?> json)
    : this (
        latitude:     json['latitude'] as double,
        longitude:    json['longitude'] as double,
        locationName: json['location-name'] as String
    );

  Map<String, Object?> toJson() {
    return{
      'latitude'      : latitude,
      'longitude'     : longitude,
      'location-name' : locationName
    };
  }

}