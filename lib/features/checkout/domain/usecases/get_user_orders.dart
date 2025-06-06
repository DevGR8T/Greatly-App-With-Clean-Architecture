import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/checkout/domain/entities/orders.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/check_out_repository.dart';


class GetUserOrdersParams extends Equatable {
  final int? page;
  final int? limit;

  const GetUserOrdersParams({
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [page, limit];
}

@injectable
class GetUserOrders implements UseCase<List<OrderEntity>, GetUserOrdersParams> {
  final CheckoutRepository repository;

  GetUserOrders(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetUserOrdersParams params) async {
    return await repository.getUserOrders(
      page: params.page,
      limit: params.limit,
    );
  }
}
