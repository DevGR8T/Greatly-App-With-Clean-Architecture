import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repository/cart_repository.dart';

class AddToCartParams {
  final CartItem item;

  AddToCartParams({required this.item});
}

class AddToCartUseCase implements UseCase<Cart, AddToCartParams> {
  final CartRepository repository;

  AddToCartUseCase({required this.repository});

  @override
  Future<Either<Failure, Cart>> call(AddToCartParams params) async{
    return await repository.addToCart(params.item);
  }
}