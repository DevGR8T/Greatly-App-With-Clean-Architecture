// checkout_repository_impl.dart
import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/orders.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repository/check_out_repository.dart';
import '../datasources/remote/checkout_remote_datasource.dart';

@LazySingleton(as: CheckoutRepository)
class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  CheckoutRepositoryImpl({
    required CheckoutRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Address>>> getSavedAddresses() async {
    if (await _networkInfo.isConnected) {
      try {
        final addresses = await _remoteDataSource.getSavedAddresses();
        return Right(addresses);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
Future<Either<Failure, Address>> saveAddress(Address address) async {
  if (await _networkInfo.isConnected) {
    try {
      final savedAddress = await _remoteDataSource.saveAddress(address);
      return Right(savedAddress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  } else {
    return const Left(ConnectionFailure('No internet connection'));
  }
}

@override
Future<Either<Failure, bool>> deleteAddress(String addressId) async {
  try {
    final result = await _remoteDataSource.deleteAddress(addressId);
    return Right(result);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}

  @override
  Future<Either<Failure, List<PaymentMethod>>> getSavedPaymentMethods() async {
    if (await _networkInfo.isConnected) {
      try {
        final methods = await _remoteDataSource.getSavedPaymentMethods();
        return Right(methods);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required Address shippingAddress,
    Address? billingAddress,
    String? selectedPaymentMethodId,
    String? couponCode,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final order = await _remoteDataSource.createOrder(
          cartItems: cartItems,
          shippingAddress: shippingAddress,
          billingAddress: billingAddress,
          selectedPaymentMethodId: selectedPaymentMethodId,
          couponCode: couponCode,
        );
        return Right(order);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> initializePayment({
    required String orderId,
    String? paymentMethodId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final order = await _remoteDataSource.initializePayment(
          orderId: orderId,
          paymentMethodId: paymentMethodId,
        );
        return Right(order);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PaymentResult>> confirmPayment({
    required String orderId,
    required String paymentIntentId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.confirmPayment(
          orderId: orderId,
          paymentIntentId: paymentIntentId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelOrder({required String orderId}) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.cancelOrder(orderId: orderId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById({
    required String orderId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final order = await _remoteDataSource.getOrderById(orderId: orderId);
        return Right(order);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    int? page,
    int? limit,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final orders = await _remoteDataSource.getUserOrders(
          page: page,
          limit: limit,
        );
        return Right(orders);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

@override
Future<Either<Failure, bool>> addPaymentMethod({
  required String paymentMethodId,
  bool isDefault = false,
}) async {
  if (await _networkInfo.isConnected) {
    try {
      final paymentMethod = await _remoteDataSource.addPaymentMethod(
        paymentMethodId: paymentMethodId,
        isDefault: isDefault,
      );
      final result = true; // Always true since paymentMethod cannot be null
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  } else {
    return const Left(ConnectionFailure('No internet connection'));
  }
}

@override
Future<Either<Failure, bool>> deletePaymentMethod({
  required String paymentMethodId,
}) async {
  if (await _networkInfo.isConnected) {
    try {
      final result = await _remoteDataSource.deletePaymentMethod(
        paymentMethodId: paymentMethodId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  } else {
    return const Left(ConnectionFailure('No internet connection'));
  }
}

 @override
  Future<Either<Failure, String>> createStripePortalSession({
    required String customerEmail,
    required String firebaseUid,
    String? returnUrl,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final sessionUrl = await _remoteDataSource.createStripePortalSession(
          customerEmail: customerEmail,
          firebaseUid: firebaseUid,
          returnUrl: returnUrl,
        );
        return Right(sessionUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }
}
