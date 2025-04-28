import 'package:dio/dio.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/featured_product_model.dart';

/// Abstract data source for fetching featured products from a remote server.
abstract class FeaturedProductsRemoteDataSource {
  /// Fetches a list of featured products.
  Future<List<FeaturedProductModel>> getFeaturedProducts();
}

/// Implementation of [FeaturedProductsRemoteDataSource] using Dio for HTTP requests.
class FeaturedProductsRemoteDataSourceImpl
    implements FeaturedProductsRemoteDataSource {
  final DioClient client;

  /// Initializes the data source with a Dio client.
  FeaturedProductsRemoteDataSourceImpl(this.client);

  /// Fetches featured products from the API.
  ///
  /// Returns a list of [FeaturedProductModel] if successful, or throws a [ServerException] on failure.
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