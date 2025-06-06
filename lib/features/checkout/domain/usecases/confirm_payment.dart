import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_result.dart';
import '../repository/check_out_repository.dart';


class ConfirmPaymentParams extends Equatable {
  final String orderId;
  final String paymentIntentId;

  const ConfirmPaymentParams({
    required this.orderId,
    required this.paymentIntentId,
  });

  @override
  List<Object?> get props => [orderId, paymentIntentId];
}

@injectable
class ConfirmPayment implements UseCase<PaymentResult, ConfirmPaymentParams> {
  final CheckoutRepository repository;

  ConfirmPayment(this.repository);

  @override
  Future<Either<Failure, PaymentResult>> call(ConfirmPaymentParams params) async {
    return await repository.confirmPayment(
      orderId: params.orderId,
      paymentIntentId: params.paymentIntentId,
    );
  }
}
