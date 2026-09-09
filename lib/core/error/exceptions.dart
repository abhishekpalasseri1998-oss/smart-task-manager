/// Base class for all exceptions thrown from the data layer
/// (remote data sources, local data sources, auth services).
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// Thrown when there is no internet connection or a request times out
/// before reaching the server (DNS failure, socket timeout, etc).
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.code,
    super.stackTrace,
  });
}

/// Thrown when the server responds but with an error
/// (4xx / 5xx from the Task Manager REST API).
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'Something went wrong on the server. Please try again.',
    this.statusCode,
    super.code,
    super.stackTrace,
  });
}

/// Thrown by the local cache layer (Hive/SQLite) — read/write/parse failures.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Failed to read or write local data.',
    super.code,
    super.stackTrace,
  });
}

/// Thrown by the auth layer — wraps FirebaseAuthException into
/// something with a user-friendly message.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Optional but handy: for client-side form/input validation failures
/// (e.g. weak password, invalid email) before hitting Firebase at all.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}