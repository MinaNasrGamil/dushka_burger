
import 'package:dushka_burger/core/error/exception.dart';
import 'package:dushka_burger/core/error/failure.dart';

class ErrorMapper {
  /// Convert Exceptions thrown from data layer into Failures for UI.
  static Failure mapToFailure(Object error) {
    if (error is UnauthorizedException) {
      return UnauthorizedFailure(error.message ?? 'Unauthorized');
    }

    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }

    if (error is ParsingException) {
      return ParsingFailure(error.message);
    }

    if (error is ServerException) {
      return ServerFailure(
        message: error.message ?? 'Server error',
        statusCode: error.statusCode,
      );
    }

    return const UnknownFailure();
  }
}
