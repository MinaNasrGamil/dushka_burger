
import 'dart:convert';
import 'package:dio/dio.dart';

/// Interceptor that adds HTTP Basic Auth to every request.
/// Usage:
/// dio.interceptors.add(BasicAuthInterceptor(username: 'testapp', password: '...'));
class BasicAuthInterceptor extends Interceptor {
  final String username;
  final String password;

  BasicAuthInterceptor({
    required this.username,
    required this.password,
  });

  // Build once and reuse
  late final String _authHeader =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Don’t override if caller explicitly set Authorization.
    options.headers.putIfAbsent('Authorization', () => _authHeader);
    // Ensure JSON content-type for safety (can be overridden per request).
    options.headers.putIfAbsent('Content-Type', () => 'application/json');
    super.onRequest(options, handler);
  }
}
