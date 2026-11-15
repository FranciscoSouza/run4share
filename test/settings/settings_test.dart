import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/links.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/invite/invite_screen.dart';
import 'package:run4share/features/settings/settings_screen.dart';

import '../helpers/fake_system_actions.dart';
import '../helpers/pump_app.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../share/fake_share_actions.dart';

void main() {
  late FakeSystemActions system;
  late FakeShareActions share;

  Future<void> openSettings(
    WidgetTester tester, {
    bool hasAppLanguageScreen = true,
  }) async {
    system = FakeSystemActions(hasAppLanguageScreen: hasAppLanguageScreen);
    share = FakeShareActions();
    await tester.pumpApp(
      overrides: baseOverrides(system: system, share: share),
    );
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
  }

  Future<void> tapRow(WidgetTester tester, String title) async {
    await tester.scrollUntilVisible(
      find.text(title),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SettingsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.text(title));
    await settle(tester);
    await tester.tap(find.text(title));
    await settle(tester);
  }

  testWidgets("Language opens the phone's per-app language screen", (
    tester,
  ) async {
    await openSettings(tester);
    await tapRow(tester, 'Language');
    expect(system.languageScreens, 1);
    expect(find.text('Phone language'), findsNothing);
  });

  testWidgets('older Android: in-app list, and the app switches language', (
    tester,
  ) async {
    await openSettings(tester, hasAppLanguageScreen: false);
    await tapRow(tester, 'Language');
    expect(find.text('Phone language'), findsOneWidget);

    await tester.tap(find.text('Português'));
    await settle(tester);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget, reason: 'row subtitle');

    await tapRow(tester, 'Idioma');
    await tester.tap(find.text('Idioma do celular'));
    await settle(tester);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Rate, Privacy policy', (tester) async {
    await openSettings(tester);
    await tapRow(tester, 'Rate run4share');
    expect(system.storeListings, 1);
    await tapRow(tester, 'Privacy policy');
    expect(system.links, [AppLinks.privacyPolicy]);
  });

  testWidgets('Invite a friend: copy and share the link', (tester) async {
    await openSettings(tester);
    final clipboard = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    await tapRow(tester, 'Invite a friend');
    expect(find.byType(InviteScreen), findsOneWidget);
    expect(find.text('Bring a training partner'), findsOneWidget);

    await tester.tap(find.text(AppLinks.playStore.toString()));
    await settle(tester);
    expect(clipboard, [AppLinks.playStore.toString()]);
    expect(find.text('Link copied'), findsOneWidget);
    // It switches back to the link after two seconds.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(AppLinks.playStore.toString()), findsOneWidget);

    await tester.tap(find.text('Share invite link'));
    await settle(tester);
    expect(share.texts.single, contains(AppLinks.playStore.toString()));
    expect(share.texts.single, startsWith('I use run4share'));
  });
}
