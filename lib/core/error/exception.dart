
// lib/core/error/exception.dart

// Data-layer exceptions thrown by Remote/Data sources.
// Repositories catch these and map them to Failures.

class ServerException implements Exception {
  final int? statusCode;
  final String? message;
  final dynamic data; // optional raw response body

  ServerException({this.statusCode, this.message, this.data});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

class NetworkException implements Exception {
  final String message; // timeouts, no internet, DNS, etc.
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException(message: $message)';
}

class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException([this.message]);

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

class ParsingException implements Exception {
  final String message;
  ParsingException(this.message);

  @override
  String toString() => 'ParsingException(message: $message)';
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}
