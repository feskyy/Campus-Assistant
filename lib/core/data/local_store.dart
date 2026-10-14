import 'package:campus_assistant/core/domain/local_store.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveLocalStore implements LocalStore {
  HiveLocalStore(this.box);
  final Box<Object> box;
  static Future<HiveLocalStore> open() async {
    await Hive.initFlutter();
    return HiveLocalStore(await Hive.openBox<Object>('campus_data_v2'));
  }

  @override
  Object? read(String key) => box.get(key);
  @override
  Future<void> write(String key, Object value) => box.put(key, value);
}

// A deterministic fake for callers/tests that construct repositories without
// bootstrap. Production bootstrap injects the persistent Hive store explicitly.
final _testStores = Expando<MemoryLocalStore>();
LocalStore testStoreFor(SharedPreferences prefs) =>
    _testStores[prefs] ??= MemoryLocalStore();

Future<void> migrateLegacyStorage(
  SharedPreferences prefs,
  LocalStore store,
) async {
  for (final key
      in prefs
          .getKeys()
          .where(
            (key) =>
                key == 'favorite_news_ids' ||
                key == 'favorite_event_ids' ||
                key.startsWith('campus_cache_v1:'),
          )
          .toList()) {
    final value = prefs.get(key);
    if (value == null) {
      continue;
    }
    // Resuming a partial migration must not overwrite newer Hive values.
    if (store.read(key) == null) {
      await store.write(key, value);
    }
    if (!await prefs.remove(key)) {
      throw StateError('Не удалось завершить миграцию $key');
    }
  }
}
