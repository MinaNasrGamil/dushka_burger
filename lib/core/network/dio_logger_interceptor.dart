import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLoggerInterceptor extends Interceptor {
  final bool logRequestBody;
  final bool logResponseBody;

  DioLoggerInterceptor({
    this.logRequestBody = true,
    this.logResponseBody = false,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(options);

    final start = DateTime.now().millisecondsSinceEpoch;
    options.extra['__startTime'] = start;

    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = '***REDACTED***';
    }

    debugPrint('➡️ ${options.method} ${options.baseUrl}${options.path}');
    debugPrint('Headers: ${jsonEncode(headers)}');

    if (logRequestBody && options.data != null) {
      debugPrint('Body: ${_safe(options.data)}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(response);

    final start = response.requestOptions.extra['__startTime'] as int?;
    final ms = start == null
        ? '-'
        : (DateTime.now().millisecondsSinceEpoch - start);

    debugPrint(
      '✅ ${response.statusCode} (${ms}ms) ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );

    if (logResponseBody && response.data != null) {
      debugPrint('Response: ${_safe(response.data)}');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) return handler.next(err);

    final req = err.requestOptions;
    final start = req.extra['__startTime'] as int?;
    final ms = start == null
        ? '-'
        : (DateTime.now().millisecondsSinceEpoch - start);

    debugPrint('❌ ERROR (${ms}ms) ${req.method} ${req.baseUrl}${req.path}');
    debugPrint('Type: ${err.type}');
    debugPrint('Message: ${err.message}');
    if (err.response != null) {
      debugPrint('Status: ${err.response?.statusCode}');
      debugPrint('Data: ${_safe(err.response?.data)}');
    }

    handler.next(err);
  }

  String _safe(dynamic data) {
    try {
      if (data is String) return data;
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
