import 'package:equatable/equatable.dart';

/// Failures are what the domain/repository layer returns upward
/// (e.g. as the Left side of an Either, or as a Bloc/Riverpod error state).
/// UI widgets switch on Failure type, never on raw exceptions.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.', super.code});
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({super.message = 'Server error occurred.', this.statusCode, super.code});

  @override
  List<Object?> get props => [message, code, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local storage error.', super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred.', super.code});
}