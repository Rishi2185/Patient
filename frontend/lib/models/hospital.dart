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
}

/// A facility/amenity offered at a hospital, with an icon label.
class HospitalFacility {
  final String label;
  final String icon; // material icon code point key, resolved in widget

  const HospitalFacility(this.label, this.icon);
}
