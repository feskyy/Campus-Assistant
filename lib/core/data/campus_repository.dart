import 'package:campus_assistant/core/domain/local_store.dart';

import 'local_store.dart';

import 'package:campus_assistant/core/domain/network_exception.dart';

import 'network_error_interceptor.dart';

import 'dart:convert';

import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/core/domain/campus_data.dart';
export 'package:campus_assistant/core/domain/campus_data.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampusRepository implements CampusDataSource {
  CampusRepository({
    required this.prefs,
    LocalStore? store,
    String? baseUrl,
    Dio? dio,
  }) : store = store ?? testStoreFor(prefs),
       baseUrl = baseUrl ?? const String.fromEnvironment('CAMPUS_API_URL'),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 5),
               receiveTimeout: const Duration(seconds: 5),
             ),
           ) {
    _dio.interceptors.add(NetworkErrorInterceptor());
  }
  final SharedPreferences prefs;
  final LocalStore store;
  final String baseUrl;
  final Dio _dio;
  String get _cacheKey => 'campus_cache_v1:$baseUrl';
  @override
  CampusData? cached() {
    final raw = store.read(_cacheKey) as String?;
    if (raw == null) return null;
    try {
      return CampusData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        (jsonDecode(raw) as Map<String, dynamic>)['_source'] ==
                'Демонстрационные данные REST API — не данные университета'
            ? 'Сохранённые демонстрационные данные REST API — не данные университета'
            : 'Сохранённые данные API',
        cachedAt: DateTime.tryParse(
          (jsonDecode(raw) as Map<String, Object?>)['_cachedAt'] as String? ??
              '',
        ),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<CampusData> load() async {
    if (baseUrl.isEmpty) {
      return CampusData(
        lessons: StaticData.lessons,
        news: StaticData.news,
        events: StaticData.events,
        subjects: StaticData.subjects,
        teachers: StaticData.teachers,
        buildings: StaticData.buildings,
        source: 'Локальные демонстрационные данные — не данные университета',
      );
    }
    try {
      final root = baseUrl.replaceFirst(RegExp(r'/$'), '');
      final responses = await Future.wait(
        [
          '/schedule',
          '/news',
          '/events',
          '/subjects',
          '/teachers',
          '/buildings',
        ].map((path) async {
          try {
            return await _dio.get<Object?>('$root$path');
          } on DioException catch (error) {
            // Catalogs are optional for older three-endpoint backends.
            if (['/subjects', '/teachers', '/buildings'].contains(path) &&
                error.response?.statusCode == 404) {
              return Response<Object?>(
                requestOptions: error.requestOptions,
                data: const <Object?>[],
              );
            }
            rethrow;
          }
        }),
      );
      final data = CampusData.fromJson(
        {
          'lessons': responses[0].data,
          'news': responses[1].data,
          'events': responses[2].data,
          'subjects': responses[3].data,
          'teachers': responses[4].data,
          'buildings': responses[5].data,
        },
        responses
                .take(3)
                .every((e) => e.headers.value('X-Campus-Data-Source') == 'demo')
            ? 'Демонстрационные данные REST API — не данные университета'
            : 'Данные API',
      );
      await store.write(
        _cacheKey,
        jsonEncode({
          ...data.toJson(),
          '_source': data.source,
          '_cachedAt': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      return data;
    } catch (error) {
      final cache = cached();
      if (cache != null) {
        return CampusData(
          lessons: cache.lessons,
          news: cache.news,
          events: cache.events,
          subjects: cache.subjects,
          teachers: cache.teachers,
          buildings: cache.buildings,
          source: cache.source,
          cachedAt: cache.cachedAt,
          warning: 'Обновление не удалось. Показан сохранённый кэш.',
        );
      }
      if (error is DioException) {
        throw mapNetworkError(error);
      }
      if (error is FormatException || error is TypeError) {
        throw const ParsingException();
      }
      rethrow;
    }
  }
}
