String jsonString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Некорректное поле $key');
  }
  return value;
}

DateTime jsonDate(Map<String, dynamic> json, String key) {
  final value = DateTime.tryParse(jsonString(json, key));
  if (value == null) throw FormatException('Некорректная дата $key');
  return value;
}

int jsonInt(Map<String, dynamic> json, String key, int min, int max) {
  final value = json[key];
  if (value is! int || value < min || value > max) {
    throw FormatException('Некорректное поле $key');
  }
  return value;
}
