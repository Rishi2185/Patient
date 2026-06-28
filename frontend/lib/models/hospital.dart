/// A hospital / clinic that doctors are affiliated with.
class Hospital {
  final String id;
  final String name;
  final String address;
  final String city;
  final double rating;
  final String phone;
  final String imageUrl;
  final List<String> galleryUrls;
  final List<String> departments;
  final List<HospitalFacility> facilities;
  final String about;
  final String openHours; // e.g. "Open 24 hours"
  final double distanceKm;
  final double latitude;
  final double longitude;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.rating,
    required this.phone,
    required this.imageUrl,
    required this.galleryUrls,
    required this.departments,
    required this.facilities,
    required this.about,
    required this.openHours,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        address: (json['address'] ?? '') as String,
        city: (json['city'] ?? '') as String,
        rating: ((json['rating'] ?? 0) as num).toDouble(),
        phone: (json['phone'] ?? '') as String,
        imageUrl: (json['imageUrl'] ?? '') as String,
        galleryUrls:
            (json['galleryUrls'] as List?)?.map((e) => e as String).toList() ??
                const [],
        departments:
            (json['departments'] as List?)?.map((e) => e as String).toList() ??
                const [],
        facilities: (json['facilities'] as List?)
                ?.map((e) => HospitalFacility.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        about: (json['about'] ?? '') as String,
        openHours: (json['openHours'] ?? '') as String,
        distanceKm: ((json['distanceKm'] ?? 0) as num).toDouble(),
        latitude: ((json['latitude'] ?? 0) as num).toDouble(),
        longitude: ((json['longitude'] ?? 0) as num).toDouble(),
      );
}

/// A facility/amenity offered at a hospital, with an icon label.
class HospitalFacility {
  final String label;
  final String icon; // material icon code point key, resolved in widget

  const HospitalFacility(this.label, this.icon);

  factory HospitalFacility.fromJson(Map<String, dynamic> json) =>
      HospitalFacility(
        (json['label'] ?? '') as String,
        (json['icon'] ?? '') as String,
      );
}
