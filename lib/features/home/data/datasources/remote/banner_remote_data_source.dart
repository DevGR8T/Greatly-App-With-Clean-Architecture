import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/banner_models.dart';

/// Abstract data source for fetching banners from a remote server.
abstract class BannerRemoteDataSource {
  /// Fetches a list of banners from the remote server.
  Future<List<BannerModel>> getBanners();
}

/// Implementation of [BannerRemoteDataSource] using Dio for HTTP requests.
class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final DioClient client;

  /// Initializes the data source with a Dio client.
  BannerRemoteDataSourceImpl(this.client);

  /// Fetches banners from the API.
  ///
  /// Returns a list of [BannerModel] if successful, or throws a [ServerException] on failure.
  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await client.get(
        '/banners',
        queryParameters: {
          'populate': '*',
          'filters[active][\$eq]': true,
        },
      );

      print('Banner API response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> bannerJsonList = response.data['data'] ?? [];
        print('Banner JSON list length: ${bannerJsonList.length}');
        
        if (bannerJsonList.isEmpty) {
          print('No banners found. Check if you created banners in Strapi.');
          return [];
        }

        return bannerJsonList
            .map((json) => BannerModel.fromJson(json))
            .toList();
      } else {
        throw ServerException('Failed to load banners: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getBanners: ${e.message}');
      print('DioException response: ${e.response?.data}');
      throw ServerException(e.message ?? 'Unknown error occurred');
    } catch (e) {
      print('Unexpected error in getBanners: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}