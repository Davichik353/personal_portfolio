import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:per_port/main.dart';
import 'package:per_port/screens/projects_screen.dart';
import 'package:per_port/widgets/custom_app_bar.dart';

Future<void> pumpPortfolio(
  WidgetTester tester, {
  Size size = const Size(320, 800),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> selectSection(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Разделы портфолио'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(PopupMenuItem<PortfolioSection>, label));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('Portfolio lays out without overflow at width $width', (
      tester,
    ) async {
      await pumpPortfolio(tester, size: Size(width, 900));

      expect(find.text('Абдурасулов Давлатбек'), findsOneWidget);
      expect(find.text('Weather App'), findsOneWidget);
      expect(find.text('AR Compass'), findsOneWidget);
      await tester.ensureVisible(find.text('Контакты').last);
      await tester.pumpAndSettle();
      expect(find.text('abddavlat2@gmail.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Narrow phone remains usable with doubled text', (tester) async {
    await pumpPortfolio(tester, textScale: 2);

    await selectSection(tester, 'Проекты');
    await tester.ensureVisible(find.text('Все проекты'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Все проекты'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectsScreen), findsOneWidget);
    expect(find.text('Мои проекты'), findsOneWidget);
    await tester.ensureVisible(find.text('Все репозитории на GitHub'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Menu scrolls to projects and contacts', (tester) async {
    await pumpPortfolio(tester);

    await selectSection(tester, 'Проекты');
    final projectsTop = tester.getTopLeft(find.text('Проекты')).dy;
    expect(projectsTop, greaterThanOrEqualTo(kToolbarHeight));
    expect(projectsTop, lessThan(200));

    await selectSection(tester, 'Контакты');
    final contactsTop = tester.getTopLeft(find.text('Контакты')).dy;
    expect(contactsTop, greaterThanOrEqualTo(kToolbarHeight));
    expect(contactsTop, lessThan(200));
    expect(find.text('abddavlat2@gmail.com').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All projects route opens and returns to the portfolio', (
    tester,
  ) async {
    await pumpPortfolio(tester);
    await selectSection(tester, 'Проекты');
    await tester.ensureVisible(find.text('Все проекты'));
    await tester.tap(find.text('Все проекты'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectsScreen), findsOneWidget);
    expect(find.text('Мои проекты'), findsOneWidget);
    expect(find.text('Weather App'), findsOneWidget);
    expect(find.text('AR Compass'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectsScreen), findsNothing);
    expect(find.text('Davichik353'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Experience details expand and collapse', (tester) async {
    await pumpPortfolio(tester);
    await selectSection(tester, 'Опыт');

    const detail = '• Поддержка клиентов и техническая помощь.';
    expect(find.text(detail), findsNothing);
    await tester.tap(find.text('Оператор в UCELL'));
    await tester.pumpAndSettle();
    expect(find.text(detail), findsOneWidget);
    await tester.tap(find.text('Оператор в UCELL'));
    await tester.pumpAndSettle();
    expect(find.text(detail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Certificate opens, zooms and closes in short landscape', (
    tester,
  ) async {
    await pumpPortfolio(tester, size: const Size(812, 320));
    await tester.ensureVisible(find.text('Посмотреть сертификат'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Посмотреть сертификат'));
    await tester.pumpAndSettle();

    final viewer = find.byType(InteractiveViewer);
    final image = find.descendant(of: viewer, matching: find.byType(Image));
    expect(viewer, findsOneWidget);
    final originalScale = tester
        .renderObject<RenderBox>(image)
        .getTransformTo(null)
        .getMaxScaleOnAxis();
    final center = tester.getCenter(viewer);
    final first = await tester.startGesture(center - const Offset(20, 0));
    final second = await tester.startGesture(
      center + const Offset(20, 0),
      pointer: 2,
    );
    await tester.pump();
    await first.moveTo(center - const Offset(70, 0));
    await second.moveTo(center + const Offset(70, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    expect(
      tester
          .renderObject<RenderBox>(image)
          .getTransformTo(null)
          .getMaxScaleOnAxis(),
      greaterThan(originalScale),
    );

    await tester.tap(find.byTooltip('Закрыть сертификат'));
    await tester.pumpAndSettle();
    expect(viewer, findsNothing);
    expect(tester.takeException(), isNull);
  });
}
