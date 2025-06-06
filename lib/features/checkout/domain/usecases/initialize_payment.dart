import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/checkout/domain/entities/orders.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';

class InitializePaymentParams extends Equatable {
  final String orderId;
  final String? paymentMethodId;

  const InitializePaymentParams({
    required this.orderId,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [orderId, paymentMethodId];
}

@injectable
class InitializePayment implements UseCase<OrderEntity, InitializePaymentParams> {
  final CheckoutRepository repository;

  InitializePayment(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(InitializePaymentParams params) async {
    return await repository.initializePayment(
      orderId: params.orderId,
      paymentMethodId: params.paymentMethodId,
    );
  }
}