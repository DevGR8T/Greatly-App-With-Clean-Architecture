import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../domain/entities/payment_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_stripe_portal_session.dart';
import '../../domain/usecases/delete_address.dart';
import '../../domain/usecases/get_saved_addresses.dart';
import '../../domain/usecases/get_saved_payment_methods.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/initialize_payment.dart';
import '../../domain/usecases/confirm_payment.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/get_order_by_id.dart';
import '../../domain/usecases/get_user_orders.dart';
import '../../domain/usecases/add_payment_method.dart';
import '../../domain/usecases/delete_payment_method.dart';
import '../../domain/usecases/save_address.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final SaveAddress saveAddress;
  final GetSavedAddresses getSavedAddresses;
  final DeleteAddress deleteAddress;
  final GetSavedPaymentMethods getSavedPaymentMethods;
  final CreateOrder createOrder;
  final InitializePayment initializePayment;
  final ConfirmPayment confirmPayment;
  final CancelOrder cancelOrder;
  final GetOrderById getOrderById;
  final GetUserOrders getUserOrders;
  final AddPaymentMethod addPaymentMethod;
  final DeletePaymentMethod deletePaymentMethod;
  final CreateStripePortalSession createStripePortalSession;
  
  CheckoutBloc({
    required this.saveAddress,
    required this.getSavedAddresses,
    required this.deleteAddress,
    required this.getSavedPaymentMethods,
    required this.createOrder,
    required this.initializePayment,
    required this.confirmPayment,
    required this.cancelOrder,
    required this.getOrderById,
    required this.getUserOrders,
    required this.addPaymentMethod,
    required this.deletePaymentMethod,
    required this.createStripePortalSession,
  }) : super(CheckoutInitial()) {
    on<SaveAddressEvent>(_onSaveAddress);
    on<LoadSavedAddresses>(_onLoadSavedAddresses);
    on<DeleteAddressEvent>(_onDeleteAddress);
    on<LoadSavedPaymentMethods>(_onLoadSavedPaymentMethods);
    on<CreateOrderEvent>(_onCreateOrder);
    on<InitializePaymentEvent>(_onInitializePayment);
    on<ProcessStripePayment>(_onProcessStripePayment);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
    on<CancelOrderEvent>(_onCancelOrder);
    on<AddPaymentMethodEvent>(_onAddPaymentMethod);
    on<DeletePaymentMethodEvent>(_onDeletePaymentMethod);
    on<RefreshPaymentMethodsEvent>(_onRefreshPaymentMethods);
    on<CreateStripePortalSessionEvent>(_onCreateStripePortalSession);
  }
  
Future<void> _onSaveAddress(
  SaveAddressEvent event,
  Emitter<CheckoutState> emit,
) async {
  emit(AddressSaving());
  final result = await saveAddress(event.address);
  result.fold(
    (failure) => emit(AddressSaveFailure(failure.message)),
    (savedAddress) {
      emit(AddressSaveSuccess(savedAddress));
      // Immediately reload addresses after a successful save
      add(LoadSavedAddresses());
    },
  );
}

  Future<void> _onLoadSavedAddresses(
    LoadSavedAddresses event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(AddressesLoading());
    final addressesResult = await getSavedAddresses(NoParams());

    addressesResult.fold(
      (failure) => emit(AddressesError(failure.message)),
      (addresses) => emit(AddressesLoaded(addresses)),
    );
  }

Future<void> _onDeleteAddress(
  DeleteAddressEvent event,
  Emitter<CheckoutState> emit,
) async {

  
  try {
    final result = await deleteAddress(DeleteAddressParams(
      addressId: event.addressId.toString(),
    ));

    await result.fold(
      (failure) async {

        if (!emit.isDone) {
          emit(AddressDeletionError(failure.message));
        }
      },
      (success) async {
        if (success) {

          
          // Emit success state first
          if (!emit.isDone) {
            emit(AddressDeleted());
          }
          
          // Emit loading state to force UI refresh
          if (!emit.isDone) {
            emit(AddressesLoading());
          }
          

          final addressesResult = await getSavedAddresses(NoParams());
          
          await addressesResult.fold(
            (failure) async {

              if (!emit.isDone) {
                emit(AddressesError(failure.message));
              }
            },
            (addresses) async {

              if (!emit.isDone) {
                emit(AddressesLoaded(addresses));
              }
            },
          );
        } else {

          if (!emit.isDone) {
            emit(const AddressDeletionError('Failed to delete address'));
          }
        }
      },
    );
  } catch (e) {

    if (!emit.isDone) {
      emit(AddressDeletionError('Failed to delete address: ${e.toString()}'));
    }
  }
}


  

  Future<void> _onLoadSavedPaymentMethods(
    LoadSavedPaymentMethods event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(PaymentMethodsLoading());
    final paymentMethodsResult = await getSavedPaymentMethods(NoParams());

    paymentMethodsResult.fold(
      (failure) => emit(PaymentMethodsError(failure.message)),
      (paymentMethods) => emit(PaymentMethodsLoaded(paymentMethods)),
    );
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final orderResult = await createOrder(CreateOrderParams(
      cartItems: event.cartItems,
      shippingAddress: event.shippingAddress,
      billingAddress: event.billingAddress,
      selectedPaymentMethodId: event.selectedPaymentMethodId,
      couponCode: event.couponCode,
    ));

    orderResult.fold(
      (failure) => emit(OrderCreationError(failure.message)),
      (order) => emit(OrderCreated(order)),
    );
  }

  Future<void> _onInitializePayment(
    InitializePaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final orderResult = await initializePayment(InitializePaymentParams(
      orderId: event.orderId,
      paymentMethodId: event.paymentMethodId,
    ));

    orderResult.fold(
      (failure) => emit(PaymentInitializationError(failure.message)),
      (order) => emit(PaymentInitialized(order)),
    );
  }

 Future<void> _onProcessStripePayment(
  ProcessStripePayment event,
  Emitter<CheckoutState> emit,
) async {
  emit(PaymentInProgress());
  




  
  try {
    final clientSecret = event.order.clientSecret;
    if (clientSecret == null) {

      emit(const PaymentError('Missing payment intent client secret'));
      return;
    }


    await stripe.Stripe.instance.initPaymentSheet(
      paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Your Store Name',
        style: ThemeMode.system,
      ),
    );



    await stripe.Stripe.instance.presentPaymentSheet();


    // Payment succeeded
    if (event.order.id != null && event.order.paymentIntentId != null) {

      add(ConfirmPaymentEvent(
        orderId: event.order.id!,
        paymentIntentId: event.order.paymentIntentId!,
      ));
    } else {

      emit(const PaymentError('Missing order ID or payment intent ID'));
    }
    
  } on stripe.StripeException catch (e) {




    
    // Handle specific error codes
    if (e.error.code == 'PaymentSheetNotAvailable') {
      emit(const PaymentError('Payment method not available. Please try again.'));
    } else if (e.error.code == 'Canceled') {
      emit(const PaymentError('Payment was canceled'));
    } else {
      emit(PaymentError('Payment failed: ${e.error.localizedMessage ?? e.error.code}'));
    }
    
    if (event.order.id != null) {
      add(CancelOrderEvent(orderId: event.order.id!));
    }
    
  } catch (e) {


    
    emit(PaymentError('Payment error: ${e.toString()}'));
    
    if (event.order.id != null) {
      add(CancelOrderEvent(orderId: event.order.id!));
    }
  }
}

  Future<void> _onConfirmPayment(
    ConfirmPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(PaymentInProgress());
    final result = await confirmPayment(ConfirmPaymentParams(
      orderId: event.orderId,
      paymentIntentId: event.paymentIntentId,
    ));

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (paymentResult) {
        if (paymentResult.status == PaymentStatus.success) {
          emit(PaymentConfirmed(event.orderId));
        } else {
          emit(PaymentError(
              paymentResult.errorMessage ?? 'Payment confirmation failed'));
        }
      },
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final result = await cancelOrder(CancelOrderParams(orderId: event.orderId));

    result.fold(
      (failure) => emit(OrderCancellationError(failure.message)),
      (success) {
        if (success) {
          emit(OrderCancelled());
        } else {
          emit(const OrderCancellationError('Failed to cancel order'));
        }
      },
    );
  }

  Future<void> _onAddPaymentMethod(
    AddPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final result = await addPaymentMethod(AddPaymentMethodParams(
      paymentMethodId: event.paymentMethodId,
      isDefault: event.isDefault,
    ));

    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (success) {
        if (success) {
          emit(PaymentMethodAdded());
          // Refresh payment methods list after successful addition
          add(const RefreshPaymentMethodsEvent());
        } else {
          emit(const PaymentMethodError('Failed to add payment method'));
        }
      },
    );
  }

Future<void> _onDeletePaymentMethod(
    DeletePaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) async {

    
    try {
      // Add a small delay to ensure UI updates properly
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await deletePaymentMethod(DeletePaymentMethodParams(
        paymentMethodId: event.paymentMethodId.toString(),
      ));

      result.fold(
        (failure) {

          emit(PaymentMethodDeletionError(failure.message));
        },
        (success) {
          if (success) {

            emit(PaymentMethodDeleted());
           add(LoadSavedPaymentMethods());
          } else {

            emit(const PaymentMethodDeletionError('Failed to delete payment method'));
          }
        },
      );
    } catch (e, stackTrace) {


      emit(PaymentMethodDeletionError('Failed to delete payment method: ${e.toString()}'));
    }
  }


  Future<void> _onRefreshPaymentMethods(
    RefreshPaymentMethodsEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(PaymentMethodsLoading());

    final paymentMethodsResult = await getSavedPaymentMethods(NoParams());

    paymentMethodsResult.fold(
      (failure) => emit(PaymentMethodsError(failure.message)),
      (paymentMethods) => emit(PaymentMethodsLoaded(paymentMethods)),
    );
  }

// Handler implementation:
  Future<void> _onCreateStripePortalSession(
    CreateStripePortalSessionEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(StripePortalSessionLoading());
    final result =
        await createStripePortalSession(CreateStripePortalSessionParams(
      customerEmail: event.customerEmail,
      firebaseUid: event.firebaseUid,
      returnUrl: event.returnUrl,
    ));
    result.fold(
      (failure) => emit(StripePortalSessionError(failure.message)),
      (portalUrl) => emit(StripePortalSessionLoaded(portalUrl)),
    );
  }
}
