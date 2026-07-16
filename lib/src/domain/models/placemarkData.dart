// class PlacemarkData {
//   String address;
//   double lat;
//   double lng;

//   PlacemarkData({required this.address, required this.lat, required this.lng});
// }

import 'package:equatable/equatable.dart';

class PlacemarkData extends Equatable {
  final String address;
  final String street;
  final String locality;
  final String subLocality;
  final String administrativeArea;
  final String subAdministrativeArea;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;

  const PlacemarkData({
    required this.address,
    required this.street,
    required this.locality,
    required this.subLocality,
    required this.administrativeArea,
    required this.subAdministrativeArea,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  PlacemarkData copyWith({
    String? address,
    String? street,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) {
    return PlacemarkData(
      address: address ?? this.address,
      street: street ?? this.street,
      locality: locality ?? this.locality,
      subLocality: subLocality ?? this.subLocality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      subAdministrativeArea:
          subAdministrativeArea ?? this.subAdministrativeArea,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    address,
    street,
    locality,
    subLocality,
    administrativeArea,
    subAdministrativeArea,
    country,
    postalCode,
    latitude,
    longitude,
  ];
}
