
// lib/core/error/failure.dart

import 'package:equatable/equatable.dart';

/// Domain/UI failures. Cubits should expose these messages to the UI.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({
    String message = 'Server error',
    this.statusCode,
  }) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Data parsing error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
