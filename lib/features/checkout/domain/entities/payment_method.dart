import 'package:equatable/equatable.dart';

enum PaymentType { creditCard, paypal, applePay, googlePay }

class PaymentMethod extends Equatable {
  final int id; // Strapi auto-generated ID
  final String firebaseUserId;
  final String stripePaymentMethodId;
  final String email;
  final String? cardBrand;
  final String lastFour;
  final int? expiryDate;
  final bool isDefault;
  final PaymentType type; // This might need to be derived from card_brand or hardcoded

  const PaymentMethod({
    required this.id,
    required this.firebaseUserId,
    required this.stripePaymentMethodId,
    required this.email,
    this.cardBrand,
    required this.lastFour,
    this.expiryDate,
    this.isDefault = false,
    this.type = PaymentType.creditCard, // Default since not in backend schema
  });

  @override
  List<Object?> get props => [
    id,
    firebaseUserId,
    stripePaymentMethodId,
    email,
    cardBrand,
    lastFour,
    expiryDate,
    isDefault,
    type,
  ];
}