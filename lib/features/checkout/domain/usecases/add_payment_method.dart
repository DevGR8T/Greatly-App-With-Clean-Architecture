import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';

class AddPaymentMethodParams {
  final String paymentMethodId;
  final bool isDefault;

  AddPaymentMethodParams({
    required this.paymentMethodId,
    this.isDefault = false,
  });
}

@injectable
class AddPaymentMethod implements UseCase<bool, AddPaymentMethodParams> {
  final CheckoutRepository repository;

  AddPaymentMethod(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddPaymentMethodParams params) {
    return repository.addPaymentMethod(
      paymentMethodId: params.paymentMethodId,
      isDefault: params.isDefault,
    );
  }
}