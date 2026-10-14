import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

abstract interface class ExternalLinks {
  Future<bool> open(Uri uri);
}

class SystemExternalLinks implements ExternalLinks {
  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

final externalLinksProvider = Provider<ExternalLinks>(
  (ref) => SystemExternalLinks(),
);
