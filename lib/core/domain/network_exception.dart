// Extending FormatException preserves the existing caller contract while making
// failures distinguishable. No low-level Dio types leak into domain.
class NetworkException extends FormatException {
  const NetworkException([super.message = 'Нет соединения с сервером']);
}

class TimeoutException extends NetworkException {
  const TimeoutException() : super('Время ожидания сервера истекло');
}

class ServerException extends NetworkException {
  const ServerException(this.statusCode) : super('Ошибка сервера');
  final int? statusCode;
}

class ParsingException extends NetworkException {
  const ParsingException() : super('Некорректный ответ сервера');
}
