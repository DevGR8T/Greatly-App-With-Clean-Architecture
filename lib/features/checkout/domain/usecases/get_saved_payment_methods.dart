import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/checkout/domain/repository/check_out_repository.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';

@injectable
class GetSavedPaymentMethods implements UseCase<List<PaymentMethod>, NoParams> {
  final CheckoutRepository repository;

  GetSavedPaymentMethods(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethod>>> call(NoParams params) async {
    return await repository.getSavedPaymentMethods();
  }
}