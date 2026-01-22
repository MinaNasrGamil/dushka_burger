import 'package:dio/dio.dart';
import 'package:dushka_burger/core/network/basic_auth.dart';
import 'package:dushka_burger/core/network/dio_logger_interceptor.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  // ---- Singleton pattern ----
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // ---- The configured Dio instance ----
  late final Dio dio = _createDio();

  // ---- Base API URL ----
  static const String _baseUrl = 'https://dushkaburger.com/wp-json/';

  // TODO: (Optional) move credentials to a secure place / env
  static const _username = 'testapp';
  static const _password = '5S0Q YjyH 4s3G elpe 5F8v u8as';

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        contentType: 'application/json',

        // We allow any 2xx–5xx response.
        // Repositories will interpret errors.
        validateStatus: (status) => true,
      ),
    );

    // ---- Add Basic Auth to all requests ----
    dio.interceptors.add(
      BasicAuthInterceptor(username: _username, password: _password),
    );

    // ✅ Logging in debug only (safe: redacts Authorization)
    if (kDebugMode) {
      dio.interceptors.add(
        DioLoggerInterceptor(
          logRequestBody: true,
          logResponseBody: false, // keep false for reviewer-friendly logs
        ),
      );
    }

    // ---- Optional logging in debug only ----
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }

    return dio;
  }
}
