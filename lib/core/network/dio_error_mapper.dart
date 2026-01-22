
import 'package:dio/dio.dart';
import 'package:dushka_burger/core/error/exception.dart';

class DioErrorMapper {
  /// Convert DioException (timeouts, no internet, bad response...) into
  /// your app Exceptions (NetworkException, ServerException, UnauthorizedException).
  static Exception map(DioException e) {
    // If Dio gives us a response (HTTP error with body)
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Request timeout');

      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');

      case DioExceptionType.badCertificate:
        return NetworkException('Bad SSL certificate');

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return NetworkException('No internet connection');

      case DioExceptionType.badResponse:
        // We received a response but status code indicates error.
        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(_extractMessage(data) ?? 'Unauthorized');
        }

        return ServerException(
          statusCode: statusCode,
          message: _extractMessage(data) ?? 'HTTP $statusCode',
          data: data,
        );
    }
  }

  /// Use this if you want a consistent way to handle non-2xx responses
  /// even when Dio didn't throw (because validateStatus=true).
  static Exception mapResponse(Response response) {
    final code = response.statusCode ?? 0;
    final data = response.data;

    if (code == 401 || code == 403) {
      return UnauthorizedException(_extractMessage(data) ?? 'Unauthorized');
    }

    return ServerException(
      statusCode: code,
      message: _extractMessage(data) ?? 'HTTP $code',
      data: data,
    );
  }

  static String? _extractMessage(dynamic data) {
    // Tries to pull a readable message from common API patterns.
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['msg'] ?? data['error'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }
    return null;
  }
}
