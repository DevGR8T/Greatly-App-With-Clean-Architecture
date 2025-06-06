import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repository/cart_repository.dart';

class GetCartUseCase implements UseCase<Cart, NoParams> {
  final CartRepository repository;

  GetCartUseCase({required this.repository});

  @override
  Future<Either<Failure, Cart>> call(NoParams params) {
    return repository.getCart();
  }
}