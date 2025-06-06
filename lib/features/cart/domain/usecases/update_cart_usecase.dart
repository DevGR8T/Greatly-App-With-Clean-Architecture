import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repository/cart_repository.dart';

class UpdateCartItemParams {
  final CartItem item;

  UpdateCartItemParams({required this.item});
}

class UpdateCartItemUseCase implements UseCase<Cart, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItemUseCase({required this.repository});

  @override
  Future<Either<Failure, Cart>> call(UpdateCartItemParams params)async{
    return await repository.updateCartItem(params.item);
  }
}
