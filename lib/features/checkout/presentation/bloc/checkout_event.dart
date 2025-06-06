import 'package:equatable/equatable.dart';

import '../../domain/entities/address.dart' as app_entities;
import '../../domain/entities/orders.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

// Event for saving an address
class SaveAddressEvent extends CheckoutEvent {
  final app_entities.Address address;

  const SaveAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}


class LoadSavedAddresses extends CheckoutEvent {}


class LoadSavedPaymentMethods extends CheckoutEvent {}


class DeleteAddressEvent extends CheckoutEvent {
  final int addressId;

  const DeleteAddressEvent({
    required this.addressId,
  });

  @override
  List<Object?> get props => [addressId];
}


class CreateOrderEvent extends CheckoutEvent {
  final List<Map<String, dynamic>> cartItems;
  final app_entities.Address shippingAddress;
  final app_entities.Address? billingAddress;
  final String? selectedPaymentMethodId;
  final String? couponCode;

  const CreateOrderEvent({
    required this.cartItems,
    required this.shippingAddress,
    this.billingAddress,
    this.selectedPaymentMethodId,
    this.couponCode,
  });

  @override
  List<Object?> get props => [
        cartItems,
        shippingAddress,
        billingAddress,
        selectedPaymentMethodId,
        couponCode,
      ];
}

class InitializePaymentEvent extends CheckoutEvent {
  final String orderId;
  final String? paymentMethodId;

  const InitializePaymentEvent({
    required this.orderId,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [orderId, paymentMethodId];
}

class ProcessStripePayment extends CheckoutEvent {
  final OrderEntity order;

  const ProcessStripePayment(this.order);

  @override
  List<Object?> get props => [order];
}

class ConfirmPaymentEvent extends CheckoutEvent {
  final String orderId;
  final String paymentIntentId;

  const ConfirmPaymentEvent({
    required this.orderId,
    required this.paymentIntentId,
  });

  @override
  List<Object?> get props => [orderId, paymentIntentId];
}

class CancelOrderEvent extends CheckoutEvent {
  final String orderId;

  const CancelOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// Event for adding a new payment method
class AddPaymentMethodEvent extends CheckoutEvent {
  final String paymentMethodId;
  final bool isDefault;

  const AddPaymentMethodEvent({
    required this.paymentMethodId,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [paymentMethodId, isDefault];
}

// Event for deleting a payment method
class DeletePaymentMethodEvent extends CheckoutEvent {
  final int paymentMethodId;

  const DeletePaymentMethodEvent({
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [paymentMethodId];
}

// Event for refreshing payment methods
class RefreshPaymentMethodsEvent extends CheckoutEvent {
  const RefreshPaymentMethodsEvent();
}

// Event for creating a Stripe portal session and opening the payment portal
class CreateStripePortalSessionEvent extends CheckoutEvent {
  final String customerEmail;
  final String firebaseUid;
  final String? returnUrl;

  const CreateStripePortalSessionEvent({
    required this.customerEmail,
    required this.firebaseUid,
    this.returnUrl,
  });

  @override
  List<Object?> get props => [customerEmail, firebaseUid, returnUrl];
}