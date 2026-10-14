abstract interface class LocalStore {
  Object? read(String key);
  Future<void> write(String key, Object value);
}

class MemoryLocalStore implements LocalStore {
  final Map<String, Object> values = {};
  @override
  Object? read(String key) => values[key];
  @override
  Future<void> write(String key, Object value) async {
    values[key] = value;
  }
}
