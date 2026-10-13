import 'dart:convert';

import 'package:campus_assistant/core/data/static_data.dart';
import 'package:campus_assistant/core/domain/campus_data.dart';
export 'package:campus_assistant/core/domain/campus_data.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampusRepository implements CampusDataSource {
  CampusRepository({required this.prefs, String? baseUrl, Dio? dio})
    : baseUrl = baseUrl ?? const String.fromEnvironment('CAMPUS_API_URL'),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );
  final SharedPreferences prefs;
  final String baseUrl;
  final Dio _dio;
  String get _cacheKey => 'campus_cache_v1:$baseUrl';
  @override
  CampusData? cached() {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return CampusData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        (jsonDecode(raw) as Map<String, dynamic>)['_source'] ==
                'Демонстрационные данные REST API — не данные университета'
            ? 'Сохранённые демонстрационные данные REST API — не данные университета'
            : 'Сохранённые данные API',
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
        ].map((path) => _dio.get<dynamic>('$root$path')),
      );
      final data = CampusData.fromJson(
        {
          'lessons': responses[0].data,
          'news': responses[1].data,
          'events': responses[2].data,
        },
        responses.every(
              (e) => e.headers.value('X-Campus-Data-Source') == 'demo',
            )
            ? 'Демонстрационные данные REST API — не данные университета'
            : 'Данные API',
      );
      final saved = await prefs.setString(
        _cacheKey,
        jsonEncode({...data.toJson(), '_source': data.source}),
      );
      return saved
          ? data
          : CampusData(
              lessons: data.lessons,
              news: data.news,
              events: data.events,
              source: data.source,
              warning: 'Не удалось сохранить офлайн-кэш',
            );
    } catch (error) {
      final cache = cached();
      if (cache != null) {
        return CampusData(
          lessons: cache.lessons,
          news: cache.news,
          events: cache.events,
          source: cache.source,
          warning: 'Обновление не удалось. Показан сохранённый кэш.',
        );
      }
      throw const FormatException(
        'Не удалось загрузить данные API. Проверьте подключение и адрес сервера.',
      );
    }
  }
}
