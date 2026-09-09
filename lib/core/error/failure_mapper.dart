import 'exceptions.dart';
import 'failures.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) {
    return NetworkFailure(message: error.message, code: error.code);
  } else if (error is ServerException) {
    return ServerFailure(
      message: error.message,
      code: error.code,
      statusCode: error.statusCode,
    );
  } else if (error is CacheException) {
    return CacheFailure(message: error.message, code: error.code);
  } else if (error is AuthException) {
    return AuthFailure(message: error.message, code: error.code);
  } else if (error is ValidationException) {
    return ValidationFailure(message: error.message, code: error.code);
  }
  return UnknownFailure(message: error.toString());
}