import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:per_port/utils/external_links.dart';

const _launcher = MethodChannel('plugins.flutter.io/url_launcher');

Future<void> _pumpLink(WidgetTester tester, Uri uri) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => openExternalLink(context, uri),
            child: const Text('Открыть ссылку'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_launcher, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('Links launch directly in an external application', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_launcher, (call) async {
          calls.add(call);
          return true;
        });
    final uri = Uri.parse('https://github.com/Davichik353');
    await _pumpLink(tester, uri);
    await tester.tap(find.text('Открыть ссылку'));
    await tester.pumpAndSettle();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'launch');
    expect(calls.single.arguments['url'], uri.toString());
    expect(calls.single.arguments['useWebView'], isFalse);
    expect(calls.single.arguments['useSafariVC'], isFalse);
    expect(find.byType(SnackBar), findsNothing);
  });

  for (final throwsPlatformException in [false, true]) {
    testWidgets(
      'Unavailable handler offers copying ($throwsPlatformException)',
      (tester) async {
        String? copiedText;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_launcher, (call) async {
              if (throwsPlatformException) {
                throw PlatformException(code: 'NO_HANDLER');
              }
              return false;
            });
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'Clipboard.setData') {
                copiedText = call.arguments['text'] as String;
              }
              return null;
            });
        final uri = Uri.parse('mailto:abddavlat2@gmail.com');
        await _pumpLink(tester, uri);
        await tester.tap(find.text('Открыть ссылку'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Не удалось открыть'), findsOneWidget);
        await tester.tap(find.text('Копировать'));
        await tester.pumpAndSettle();
        expect(copiedText, uri.toString());
        expect(find.text('Скопировано'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
