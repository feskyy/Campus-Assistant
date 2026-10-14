import 'package:campus_assistant/core/router/push_destination.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('push routes resolve only registered named destinations', () {
    final named = PushDestination.fromData({'route': 'news', 'id': 'a/b'})!;
    expect(named.name, Routes.news);
    expect(named.pathParameters, {'id': 'a/b'});
    expect(PushDestination.fromData({'route': '/event/e1'})!.pathParameters, {
      'id': 'e1',
    });
    expect(
      PushDestination.fromData({'route': '/feed?tab=events'})!.queryParameters,
      {'tab': 'events'},
    );
    expect(
      PushDestination.fromData({'route': 'https://evil.test/news/n1'}),
      isNull,
    );
    expect(PushDestination.fromData({'route': '/missing'}), isNull);
    expect(PushDestination.fromData({'route': 'news'}), isNull);
    expect(PushDestination.fromData({'route': 42}), isNull);
  });
}
