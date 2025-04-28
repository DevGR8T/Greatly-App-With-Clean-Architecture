import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../model/category_model.dart';

/// Abstract data source for fetching categories from a remote server.
abstract class CategoryRemoteDataSource {
  /// Fetches a list of categories.
  Future<List<CategoryModel>> getCategories();
}

/// Implementation of [CategoryRemoteDataSource] using Dio for HTTP requests.
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient client;

  /// Initializes the data source with a Dio client.
  CategoryRemoteDataSourceImpl(this.client);

  /// Fetches categories from the API.
  ///
  /// Returns a list of [CategoryModel] if successful, or throws a [ServerException] on failure.
  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await client.get(
        '/categories',
        queryParameters: {
          'populate': '*', // Populate related data if needed.
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJsonList = response.data['data'];
        return categoriesJsonList
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        throw ServerException('Failed to load categories');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error occurred');
    }
  }
}