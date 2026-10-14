import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_assistant/core/di/external_links.dart';
import 'package:campus_assistant/l10n/ui_text.dart';

Future<void> copyEntityText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(strings(context).copiedContent)));
  }
}

Future<void> openEntityLink(
  BuildContext context,
  WidgetRef ref,
  Uri uri,
  String fallback,
) async {
  final opened = await ref.read(externalLinksProvider).open(uri);
  if (!opened && context.mounted) {
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          uri.scheme == 'mailto'
              ? strings(c).detailContact
              : strings(c).detailAddress,
        ),
        content: SelectableText(fallback),
        actions: [
          TextButton(
            onPressed: () => copyEntityText(c, fallback),
            child: Text(strings(c).detailCopy),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(tr(c, 'Понятно')),
          ),
        ],
      ),
    );
  }
}

Uri addressDirections(String address) => Uri.https(
  'www.google.com',
  '/maps/dir/',
  {'api': '1', 'destination': address},
);
