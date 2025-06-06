import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/address.dart';
import '../repository/check_out_repository.dart';

class SaveAddress {
  final CheckoutRepository repository;

  SaveAddress(this.repository);

  Future<Either<Failure, Address>> call(Address address) {
    return repository.saveAddress(address);
  }
}