import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';

class DeleteAddress implements UseCase<bool, DeleteAddressParams> {
  final CheckoutRepository repository;

  DeleteAddress(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteAddressParams params) async {
    return await repository.deleteAddress(params.addressId);
  }
}

class DeleteAddressParams extends Equatable {
  final String addressId;

  const DeleteAddressParams({required this.addressId});

  @override
  List<Object> get props => [addressId];
}