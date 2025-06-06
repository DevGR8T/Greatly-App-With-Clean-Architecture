import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/checkout/domain/repository/check_out_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address.dart';


@injectable
class GetSavedAddresses implements UseCase<List<Address>, NoParams> {
  final CheckoutRepository repository;

  GetSavedAddresses(this.repository);

  @override
  Future<Either<Failure, List<Address>>> call(NoParams params) async {
    return await repository.getSavedAddresses();
  }
}
