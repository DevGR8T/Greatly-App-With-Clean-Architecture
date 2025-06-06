import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repository/cart_repository.dart';

class ClearCartUseCase implements UseCase<Cart, NoParams> {
  final CartRepository repository;

  ClearCartUseCase({required this.repository});

  @override
  Future<Either<Failure, Cart>> call(NoParams params) {
    return repository.clearCart();
  }
}
