import 'dart:io';

import 'package:campus_assistant/core/data/local_store.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Hive migration preserves data, removes old keys and is idempotent',
    () async {
      final directory = await Directory.systemTemp.createTemp('campus-hive-');
      Hive.init(directory.path);
      final box = await Hive.openBox<Object>('migration-test');
      final store = HiveLocalStore(box);
      SharedPreferences.setMockInitialValues({
        'favorite_news_ids': ['n1'],
        'favorite_event_ids': ['e1'],
        'campus_cache_v1:test': '{"news":[]}',
        'theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      try {
        await migrateLegacyStorage(prefs, store);
        expect(store.read('favorite_news_ids'), ['n1']);
        expect(store.read('favorite_event_ids'), ['e1']);
        expect(store.read('campus_cache_v1:test'), '{"news":[]}');
        expect(prefs.getKeys(), {'theme_mode'});
        await store.write('favorite_news_ids', ['n2']);
        await migrateLegacyStorage(prefs, store);
        await box.close();
        final reopened = await Hive.openBox<Object>('migration-test');
        expect(reopened.get('favorite_news_ids'), ['n2']);
        await reopened.close();
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
