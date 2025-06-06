import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';

class DeletePaymentMethodParams {
  final String paymentMethodId;

  DeletePaymentMethodParams({
    required this.paymentMethodId,
  });
}

@injectable
class DeletePaymentMethod implements UseCase<bool, DeletePaymentMethodParams> {
  final CheckoutRepository repository;

  DeletePaymentMethod(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeletePaymentMethodParams params) {
    return repository.deletePaymentMethod(
      paymentMethodId: params.paymentMethodId,
    );
  }
}