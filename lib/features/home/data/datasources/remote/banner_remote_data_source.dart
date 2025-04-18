import 'package:dio/dio.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/banner_models.dart';

abstract class BannerRemoteDataSource {
  Future<List<BannerModel>> getBanners();
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final DioClient client;

  BannerRemoteDataSourceImpl(this.client);

 // In banner_remote_data_source.dart, update getBanners():
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