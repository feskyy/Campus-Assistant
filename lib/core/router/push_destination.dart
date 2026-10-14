import 'routes.dart';

class PushDestination {
  const PushDestination(
    this.name, {
    this.pathParameters = const {},
    this.queryParameters = const {},
  });
  final String name;
  final Map<String, String> pathParameters, queryParameters;
  static PushDestination? fromData(Map<String, Object?> data) {
    final route = data['route'];
    if (route is! String) {
      return null;
    }
    if (Routes.paths.containsKey(route)) {
      if ([Routes.news, Routes.event, Routes.lesson].contains(route)) {
        final id = data['id'];
        return id is String && id.isNotEmpty
            ? PushDestination(route, pathParameters: {'id': id})
            : null;
      }
      return PushDestination(route);
    }
    final uri = Uri.tryParse(route);
    if (uri == null || uri.hasScheme || uri.hasAuthority) {
      return null;
    }
    for (final entry in Routes.paths.entries) {
      if (entry.value == uri.path) {
        return PushDestination(entry.key, queryParameters: uri.queryParameters);
      }
    }
    if (uri.pathSegments.length == 2 &&
        [
          Routes.news,
          Routes.event,
          Routes.lesson,
        ].contains(uri.pathSegments.first) &&
        uri.pathSegments.last.isNotEmpty) {
      return PushDestination(
        uri.pathSegments.first,
        pathParameters: {'id': uri.pathSegments.last},
      );
    }
    return null;
  }
}
