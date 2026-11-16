import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launch directly: capability checks can hide installed apps on Android 11+.
Future<void> openExternalLink(BuildContext context, Uri uri) async {
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
  } on PlatformException {
    // Keep contact details accessible even without a mail or phone handler.
  } on Exception {
    // Some platforms report an unavailable handler with a generic exception.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Не удалось открыть $uri. Можно скопировать адрес.'),
      action: SnackBarAction(
        label: 'Копировать',
        onPressed: () => copyText(context, uri.toString()),
      ),
    ),
  );
}

Future<void> copyText(BuildContext context, String value) async {
  try {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Скопировано')));
  } on Exception {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Не удалось скопировать. Выделите адрес вручную.'),
      ),
    );
  }
}
