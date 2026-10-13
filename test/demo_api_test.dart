import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:campus_assistant/core/data/campus_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealHttp extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('CAMPUS_TEST_API');
  test(
    'Flutter repository consumes the actual Python demonstration backend',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () =>
            HttpOverrides.runWithHttpOverrides(() => HttpClient(), RealHttp()),
      );
      final repository = CampusRepository(prefs: prefs, baseUrl: url, dio: dio);
      final data = await repository.load();
      expect(data.source, contains('Демонстрационные данные REST API'));
      expect(data.lessons.map((e) => e.group), contains('TEST-101'));
      expect(data.news.first.body, contains('полный текст'));
      expect(data.events, isNotEmpty);
      expect(repository.cached()!.source, contains('демонстрационные'));
    },
    skip: url.isEmpty
        ? 'Start backend/server.py and pass --dart-define=CAMPUS_TEST_API=http://127.0.0.1:8085'
        : false,
  );
}
