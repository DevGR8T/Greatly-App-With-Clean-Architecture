import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';


class CancelOrderParams extends Equatable {
  final String orderId;

  const CancelOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

@injectable
class CancelOrder implements UseCase<bool, CancelOrderParams> {
  final CheckoutRepository repository;

  CancelOrder(this.repository);

  @override
  Future<Either<Failure, bool>> call(CancelOrderParams params) async {
    return await repository.cancelOrder(orderId: params.orderId);
  }
}
