import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repository/cart_repository.dart';

class RemoveFromCartParams {
  final String productId;

  RemoveFromCartParams({required this.productId});
}


class RemoveFromCartUseCase implements UseCase<Cart, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase({required this.repository});

  @override
  Future<Either<Failure, Cart>> call(RemoveFromCartParams params) async {
    return repository.removeFromCart(params.productId);
  }
}