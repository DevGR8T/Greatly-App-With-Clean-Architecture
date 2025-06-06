import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    super.id,
    required super.firebaseUserId,
    required super.streetAddress,
    super.apartmentSuite,
    required super.city,
    required super.stateProvince,
    required super.postalCode,
    super.country = "United States",
    super.isDefault = false,
  });

 factory AddressModel.fromJson(Map<String, dynamic> json) {
  return AddressModel(
    id: json['id'] as int?,
    firebaseUserId: json['firebase_user_id'] as String? ?? "",
    streetAddress: json['street_address'] as String? ?? "",
    apartmentSuite: json['apartment_suite'] as String? ?? "",
    city: json['city'] as String? ?? "",
    stateProvince: json['state_province'] as String? ?? "",
    postalCode: json['postal_code'] as String? ?? "",
    country: json['country'] as String? ?? "United States",
    isDefault: json['is_default'] as bool? ?? false,
  );
}

  factory AddressModel.fromEntity(Address address) {
    return AddressModel(
      firebaseUserId: address.firebaseUserId,
      streetAddress: address.streetAddress,
      apartmentSuite: address.apartmentSuite,
      city: address.city,
      stateProvince: address.stateProvince,
      postalCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firebase_user_id': firebaseUserId,
      'street_address': streetAddress,
      'apartment_suite': apartmentSuite,
      'city': city,
      'state_province': stateProvince,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
    };
  }
}