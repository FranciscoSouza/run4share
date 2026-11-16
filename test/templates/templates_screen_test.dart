import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/templates/template_preview_screen.dart';
import 'package:run4share/features/templates/templates_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> openSeeAll(WidgetTester tester, {bool pro = false}) async {
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(),
        proAtLaunchProvider.overrideWithValue(pro),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.byType(TemplatesScreen), findsOneWidget);
  }

  Finder grid() => find.descendant(
        of: find.byType(TemplatesScreen),
        matching: find.byType(Scrollable),
      );

  Finder tile(String name) => find.bySemanticsLabel(RegExp('^$name, '));

  testWidgets('every template, two columns, badges only when locked', (
    tester,
  ) async {
    await openSeeAll(tester);
    // Two columns: the first two tiles share a row.
    final first = tester.getRect(tile('Sunrise Half'));
    final second = tester.getRect(tile('Summit Day'));
    expect(second.top, first.top);
    expect(second.left, greaterThan(first.right));
    final badges = find.descendant(
      of: find.byType(TemplatesScreen),
      matching: find.text('PRO'),
    );
    // The five Pro templates; the six free ones have none.
    expect(badges, findsNWidgets(5));
    for (final template in storyTemplates) {
      await tester.scrollUntilVisible(
        tile(template.name),
        200,
        scrollable: grid(),
      );
      expect(tile(template.name), findsOneWidget, reason: template.name);
    }
  });

  testWidgets('with Pro, no badges', (tester) async {
    await openSeeAll(tester, pro: true);
    expect(
      find.descendant(
        of: find.byType(TemplatesScreen),
        matching: find.text('PRO'),
      ),
      findsNothing,
    );
  });

  testWidgets('a tile opens its preview', (tester) async {
    await openSeeAll(tester);
    await tester.tap(tile('Summit Day'));
    await tester.pumpAndSettle();
    expect(find.byType(TemplatePreviewScreen), findsOneWidget);
    expect(find.text('Summit Day'), findsWidgets);
  });
}
