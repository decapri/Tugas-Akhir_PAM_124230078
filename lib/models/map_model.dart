
class DonationPlace {
  final String name;
  final String type;
  final String address;
  final double lat;
  final double lng;
  final double? distance;

  DonationPlace({
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    this.distance,
  });

  DonationPlace copyWith({double? distance}) {
    return DonationPlace(
      name: name,
      type: type,
      address: address,
      lat: lat,
      lng: lng,
      distance: distance ?? this.distance,
    );
  }
}