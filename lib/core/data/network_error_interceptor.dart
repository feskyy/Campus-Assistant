import 'package:campus_assistant/core/domain/network_exception.dart';
import 'package:dio/dio.dart';

NetworkException mapNetworkError(DioException error) {
  final cause = error.error;
  if (cause is NetworkException) {
    return cause;
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const TimeoutException(),
    DioExceptionType.badResponse => ServerException(error.response?.statusCode),
    _ =>
      error.error is FormatException || error.error is TypeError
          ? const ParsingException()
          : const NetworkException(),
  };
}

class NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) =>
      handler.next(err.copyWith(error: mapNetworkError(err)));
}
