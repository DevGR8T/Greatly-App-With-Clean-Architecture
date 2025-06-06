import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/checkout/domain/entities/orders.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';


class GetOrderParams extends Equatable {
  final String orderId;

  const GetOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

@injectable
class GetOrderById implements UseCase<OrderEntity, GetOrderParams> {
  final CheckoutRepository repository;

  GetOrderById(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderParams params) async {
    return await repository.getOrderById(orderId: params.orderId);
  }
}
