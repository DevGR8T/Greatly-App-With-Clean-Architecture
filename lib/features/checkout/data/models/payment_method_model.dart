import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.firebaseUserId,
    required super.stripePaymentMethodId,
    required super.email,
    super.cardBrand,
    required super.lastFour,
    super.expiryDate,
    super.isDefault = false,
    super.type = PaymentType.creditCard,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      firebaseUserId: json['firebase_user_id'],
      stripePaymentMethodId: json['stripe_payment_method_id'],
      email: json['email'],
      cardBrand: json['card_brand'],
      lastFour: json['last4'],
      expiryDate: json['expiryDate'],
      isDefault: json['is_default'] ?? false,
      type: _determinePaymentType(json['card_brand']), // Derive from card brand
    );
  }

  factory PaymentMethodModel.fromEntity(PaymentMethod method) {
    return PaymentMethodModel(
      id: method.id,
      firebaseUserId: method.firebaseUserId,
      stripePaymentMethodId: method.stripePaymentMethodId,
      email: method.email,
      cardBrand: method.cardBrand,
      lastFour: method.lastFour,
      expiryDate: method.expiryDate,
      isDefault: method.isDefault,
      type: method.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_user_id': firebaseUserId,
      'stripe_payment_method_id': stripePaymentMethodId,
      'email': email,
      'card_brand': cardBrand,
      'last4': lastFour,
      'expiryDate': expiryDate,
      'is_default': isDefault,
    };
  }

  // Helper method to determine payment type from card brand
  static PaymentType _determinePaymentType(String? cardBrand) {
    if (cardBrand == null) return PaymentType.creditCard;
    
    switch (cardBrand.toLowerCase()) {
      case 'visa':
      case 'mastercard':
      case 'amex':
      case 'american express':
      case 'discover':
      case 'diners':
      case 'jcb':
        return PaymentType.creditCard;
      default:
        return PaymentType.creditCard;
    }
  }

  // If you need to map string to PaymentType for other purposes
  static PaymentType _mapStringToPaymentType(String type) {
    switch (type.toLowerCase()) {
      case 'creditcard':
      case 'credit_card':
        return PaymentType.creditCard;
      case 'paypal':
        return PaymentType.paypal;
      case 'applepay':
      case 'apple_pay':
        return PaymentType.applePay;
      case 'googlepay':
      case 'google_pay':
        return PaymentType.googlePay;
      default:
        return PaymentType.creditCard;
    }
  }

  static String _mapPaymentTypeToString(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return 'creditCard';
      case PaymentType.paypal:
        return 'paypal';
      case PaymentType.applePay:
        return 'applePay';
      case PaymentType.googlePay:
        return 'googlePay';
    }
  }
}