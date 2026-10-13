const List<String> _monthsGenitive = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 540 -> "09:00"
String formatMinutes(int minutes) =>
    '${_two(minutes ~/ 60)}:${_two(minutes % 60)}';

/// DateTime -> "14:05"
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// DateTime -> "17 октября"
String formatDayMonth(DateTime d) => '${d.day} ${_monthsGenitive[d.month - 1]}';
