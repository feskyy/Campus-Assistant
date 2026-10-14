import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/core/data/network_error_interceptor.dart';
import 'package:campus_assistant/core/domain/network_exception.dart';
import 'package:campus_assistant/features/schedule/domain/entities/lesson.dart';
import 'package:campus_assistant/features/feed/domain/entities/news_item.dart';
import 'package:campus_assistant/features/feed/domain/entities/campus_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final factories = <String, Object Function(Map<String, Object?>)>{
    'lesson': Lesson.fromJson,
    'news': NewsItem.fromJson,
    'event': CampusEvent.fromJson,
  };
  final payloads = <String, Map<String, Object?>>{
    'lesson': StaticData.lessons.first.toJson(),
    'news': StaticData.news.first.toJson(),
    'event': StaticData.events.first.toJson(),
  };
  for (final entry in factories.entries) {
    test('${entry.key}: valid, malformed and incomplete JSON', () {
      expect(entry.value(payloads[entry.key]!), isNotNull);
      expect(
        () => entry.value({...payloads[entry.key]!, 'id': 42}),
        throwsFormatException,
      );
      expect(() => entry.value({}), throwsFormatException);
    });
  }
  test('network errors map to typed domain exceptions', () {
    final request = RequestOptions(path: '/news');
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      expect(
        mapNetworkError(DioException(requestOptions: request, type: type)),
        isA<TimeoutException>(),
      );
    }
    expect(
      mapNetworkError(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      ),
      isA<NetworkException>(),
    );
    expect(
      mapNetworkError(
        DioException(requestOptions: request, error: const FormatException()),
      ),
      isA<ParsingException>(),
    );
    final server = mapNetworkError(
      DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<Object?>(requestOptions: request, statusCode: 503),
      ),
    );
    expect(server, isA<ServerException>());
    expect((server as ServerException).statusCode, 503);
  });
}
