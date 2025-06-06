import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final int? id;
  final String firebaseUserId;
  final String streetAddress;
  final String? apartmentSuite;
  final String city;
  final String stateProvince;
  final String postalCode;
  final String country;
  final bool isDefault;

  const Address({
    this.id,
    required this.firebaseUserId,
    required this.streetAddress,
    this.apartmentSuite,
    required this.city,
    required this.stateProvince,
    required this.postalCode,
    this.country = "United States",
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        firebaseUserId,
        streetAddress,
        apartmentSuite,
        city,
        stateProvince,
        postalCode,
        country,
        isDefault,
      ];
}
