import 'package:dio/dio.dart';
import 'package:dushka_burger/core/error/exception.dart';

abstract class GuestRemoteDataSource {
  Future<String> getGuestId();
}

class GuestRemoteDataSourceImpl implements GuestRemoteDataSource {
  final Dio dio;

  GuestRemoteDataSourceImpl(this.dio);

  @override
  Future<String> getGuestId() async {
    try {
      final response = await dio.get('guestcart/v1/guestid');

      final data = response.data;
      final guestId = (data is Map) ? data['guest_id']?.toString() : null;

      if (guestId == null || guestId.trim().isEmpty) {
        throw ParsingException('guest_id is missing or empty');
      }

      return guestId;
    } on DioException catch (e) {
      // You can refine these based on your exception classes
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw UnauthorizedException('Unauthorized (check Basic Auth)');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      }
      throw ServerException(message: 'Server error: ${e.message} ');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
