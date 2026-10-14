String jsonString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Некорректное поле $key');
  }
  return value;
}

DateTime jsonDate(Map<String, Object?> json, String key) {
  final value = DateTime.tryParse(jsonString(json, key));
  if (value == null) throw FormatException('Некорректная дата $key');
  return value;
}

int jsonInt(Map<String, Object?> json, String key, int min, int max) {
  final value = json[key];
  if (value is! int || value < min || value > max) {
    throw FormatException('Некорректное поле $key');
  }
  return value;
}

void jsonOptionalString(Map<String, Object?> json, String key) {
  if (json[key] != null) {
    jsonString(json, key);
  }
}

void jsonOptionalInt(Map<String, Object?> json, String key, int min, int max) {
  if (json[key] != null) {
    jsonInt(json, key, min, max);
  }
}

void jsonOptionalNumber(
  Map<String, Object?> json,
  String key,
  double min,
  double max,
) {
  final value = json[key];
  if (value == null) {
    return;
  }
  if (value is! num || !value.isFinite || value < min || value > max) {
    throw FormatException('Некорректное поле $key');
  }
}

List<String> jsonOptionalStrings(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return const [];
  }
  if (value is! List<Object?> ||
      value.any((item) => item is! String || item.trim().isEmpty)) {
    throw FormatException('Некорректный список $key');
  }
  return value.cast<String>();
}

List<Map<String, Object?>> jsonOptionalObjects(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const [];
  }
  if (value is! List<Object?>) {
    throw FormatException('Некорректный список $key');
  }
  return value.map((item) {
    if (item is! Map || item.keys.any((key) => key is! String)) {
      throw FormatException('Некорректный объект в $key');
    }
    return item.cast<String, Object?>();
  }).toList();
}
