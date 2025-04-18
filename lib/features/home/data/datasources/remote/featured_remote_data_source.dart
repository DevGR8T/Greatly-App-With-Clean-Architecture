import 'package:dio/dio.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/featured_product_model.dart';

abstract class FeaturedProductsRemoteDataSource {
  Future<List<FeaturedProductModel>> getFeaturedProducts();
}

class FeaturedProductsRemoteDataSourceImpl
    implements FeaturedProductsRemoteDataSource {
  final DioClient client;

  FeaturedProductsRemoteDataSourceImpl(this.client);

  @override
  Future<List<FeaturedProductModel>> getFeaturedProducts() async {
    try {
      final response = await client.get(
        '/products',
        queryParameters: {
          'populate': '*',
          'filters[featured][\$eq]': true,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJsonList = response.data['data'];
        return productsJsonList
            .map((json) => FeaturedProductModel.fromJson(json))
            .toList();
      } else {
        throw ServerException('Failed to load featured products');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error occurred');
    }
  }
}