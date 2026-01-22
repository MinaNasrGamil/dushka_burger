
import 'package:dio/dio.dart';
import 'package:dushka_burger/core/error/exception.dart';
import 'package:dushka_burger/features/menu/data/models.dart';

abstract class MenuRemoteDataSource {
  Future<List<CategoryDto>> getCategories();
  Future<ProductDto> getProductDetails(int productId);
  Future<AddonsResponseDto> getProductAddons(int productId);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryDto>> getCategories() async {
    try {
      final res = await dio.get('custom-api/v1/categories'); // GET categories [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)
      final data = res.data;

      if (data is! List) {
        throw ParsingException('Categories response is not a List');
      }

      return data
          .whereType<Map>()
          .map((e) => CategoryDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw _mapDioToException(e);
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<ProductDto> getProductDetails(int productId) async {
    try {
      final res = await dio.get(
        'custom-api/v1/products',
        queryParameters: {'product_id': productId},
      ); // GET product details [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

      final data = res.data;

      // API sometimes returns a map, sometimes a list with one item.
      if (data is Map) {
        return ProductDto.fromJson(Map<String, dynamic>.from(data));
      }

      if (data is List && data.isNotEmpty && data.first is Map) {
        return ProductDto.fromJson(Map<String, dynamic>.from(data.first));
      }

      throw ParsingException('Product details response has unexpected shape');
    } on DioException catch (e) {
      throw _mapDioToException(e);
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<AddonsResponseDto> getProductAddons(int productId) async {
    try {
      final res = await dio.get(
        'proaddon/v1/get2/',
        queryParameters: {'product_id2': productId},
      ); // GET addons/extras [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

      final data = res.data;

      if (data is! Map) {
        throw ParsingException('Addons response is not a Map');
      }

      return AddonsResponseDto.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw _mapDioToException(e);
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Exception _mapDioToException(DioException e) {
    final code = e.response?.statusCode;

    if (code == 401 || code == 403) {
      return UnauthorizedException('Unauthorized (check Basic Auth)');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException('Network/timeout error');
    }

    return ServerException(message: 'Server Exception: ${e.message}');
  }
}
