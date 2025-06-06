import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/orders.dart';
import '../../../../core/error/failure.dart';
import 'package:equatable/equatable.dart';
import '../entities/address.dart';
import '../repository/check_out_repository.dart';

@injectable
class CreateOrder implements UseCase<OrderEntity, CreateOrderParams> {
  final CheckoutRepository repository;
  
  CreateOrder(this.repository);
  
  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    return await repository.createOrder(
      cartItems: params.cartItems,
      shippingAddress: params.shippingAddress,
      billingAddress: params.billingAddress,
      selectedPaymentMethodId: params.selectedPaymentMethodId,
      couponCode: params.couponCode,
    );
  }
}

class CreateOrderParams extends Equatable {
  final List<Map<String, dynamic>> cartItems;
  final Address shippingAddress;
  final Address? billingAddress;
  final String? selectedPaymentMethodId;
  final String? couponCode;

  const CreateOrderParams({
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