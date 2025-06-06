import 'package:equatable/equatable.dart';
import '../../domain/entities/address.dart' as app_entities;
import '../../domain/entities/orders.dart';
import '../../domain/entities/payment_method.dart' as app_payment_entities;

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class AddressesLoading extends CheckoutState {}

class AddressesLoaded extends CheckoutState {
  final List<app_entities.Address> addresses;

  const AddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressesError extends CheckoutState {
  final String message;

  const AddressesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressSaving extends CheckoutState {}

class AddressSaveSuccess extends CheckoutState {
  final app_entities.Address address;

  const AddressSaveSuccess(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressSaveFailure extends CheckoutState {
  final String message;

  const AddressSaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}


class AddressDeleted extends CheckoutState {}


class AddressDeletionError extends CheckoutState {
  final String message;
  const AddressDeletionError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentMethodsLoading extends CheckoutState {}

class PaymentMethodsLoaded extends CheckoutState {
  final List<app_payment_entities.PaymentMethod> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodsError extends CheckoutState {
  final String message;

  const PaymentMethodsError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCreated extends CheckoutState {
  final OrderEntity order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreationError extends CheckoutState {
  final String message;

  const OrderCreationError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentInitialized extends CheckoutState {
  final OrderEntity order;

  const PaymentInitialized(this.order);

  @override
  List<Object?> get props => [order];
}

class PaymentInitializationError extends CheckoutState {
  final String message;

  const PaymentInitializationError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentInProgress extends CheckoutState {}

class PaymentConfirmed extends CheckoutState {
  final String orderId;

  const PaymentConfirmed(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class PaymentError extends CheckoutState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCancelled extends CheckoutState {}

class OrderCancellationError extends CheckoutState {
  final String message;

  const OrderCancellationError(this.message);

  @override
  List<Object?> get props => [message];
}

// State for payment method addition success
class PaymentMethodAdded extends CheckoutState {}

// State for payment method addition error
class PaymentMethodError extends CheckoutState {
  final String message;

  const PaymentMethodError(this.message);

  @override
  List<Object?> get props => [message];
}

// State for payment method deletion success
class PaymentMethodDeleted extends CheckoutState {}

// State for payment method deletion error
class PaymentMethodDeletionError extends CheckoutState {
  final String message;

  const PaymentMethodDeletionError(this.message);

  @override
  List<Object?> get props => [message];
}

// State when loading Stripe portal session
class StripePortalSessionLoading extends CheckoutState {}

// State when Stripe portal session is created successfully, holds the portal URL
class StripePortalSessionLoaded extends CheckoutState {
  final String portalUrl;

  const StripePortalSessionLoaded(this.portalUrl);

  @override
  List<Object?> get props => [portalUrl];
}

// State when Stripe portal session creation fails
class StripePortalSessionError extends CheckoutState {
  final String message;

  const StripePortalSessionError(this.message);

  @override
  List<Object?> get props => [message];
}