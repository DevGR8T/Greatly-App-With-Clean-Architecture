import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';

class CreateStripePortalSessionParams {
  final String customerEmail;
  final String firebaseUid;
  final String? returnUrl;

  CreateStripePortalSessionParams({
    required this.customerEmail,
    required this.firebaseUid,
    this.returnUrl,
  });
}

@injectable
class CreateStripePortalSession implements UseCase<String, CreateStripePortalSessionParams> {
  final CheckoutRepository repository;

  CreateStripePortalSession(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateStripePortalSessionParams params) {
    return repository.createStripePortalSession(
      customerEmail: params.customerEmail,
      firebaseUid: params.firebaseUid,
      returnUrl: params.returnUrl,
    );
  }
}