import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/shared/widgets/activity_card.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/grouped_list.dart';
import 'package:run4share/shared/widgets/logo.dart';
import 'package:run4share/shared/widgets/pills.dart';
import 'package:run4share/shared/widgets/segmented_toggle.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('AppLogo reads as one word', (tester) async {
    await tester.pumpInApp(const Center(child: AppLogo()));

    expect(find.bySemanticsLabel('run4share'), findsOneWidget);
  });

  testWidgets('AppButton calls back in every variant', (tester) async {
    var taps = 0;
    await tester.pumpInApp(
      Column(
        children: [
          for (final variant in AppButtonVariant.values)
            AppButton(
              label: variant.name,
              icon: AppIcons.plus,
              variant: variant,
              onPressed: () => taps++,
            ),
        ],
      ),
    );

    for (final variant in AppButtonVariant.values) {
      await tester.tap(find.text(variant.name));
    }
    expect(taps, AppButtonVariant.values.length);
  });

  testWidgets('AppPill calls back in every variant', (tester) async {
    var taps = 0;
    await tester.pumpInApp(
      Wrap(
        children: [
          for (final variant in AppPillVariant.values)
            AppPill(
              label: variant.name,
              variant: variant,
              onPressed: () => taps++,
            ),
        ],
      ),
    );

    for (final variant in AppPillVariant.values) {
      await tester.tap(find.text(variant.name));
    }
    expect(taps, AppPillVariant.values.length);
  });

  testWidgets('GroupedListTile shows a chevron only when tappable', (
    tester,
  ) async {
    await tester.pumpInApp(
      GroupedListCard(
        children: [
          GroupedListTile(icon: AppIcons.star, title: 'Tap', onTap: () {}),
          const GroupedListTile(icon: AppIcons.star, title: 'Static'),
        ],
      ),
    );

    expect(find.byIcon(AppIcons.right), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('ActivityCard shows at most three stats, labels in caps', (
    tester,
  ) async {
    await tester.pumpInApp(
      ActivityCard(
        icon: AppIcons.run,
        title: 'Lunch Run',
        subtitle: 'Strava · Thu 12 Nov · 12:31',
        stats: const [
          ActivityStat(label: 'Distance', value: '5.02', unit: 'km'),
          ActivityStat(label: 'Time', value: '33:14'),
          ActivityStat(label: 'Pace', value: '6:37', unit: '/km'),
          ActivityStat(label: 'Elevation', value: '42', unit: 'm'),
        ],
        onTap: () {},
      ),
    );

    expect(find.text('Lunch Run'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('PACE'), findsOneWidget);
    expect(find.text('ELEVATION'), findsNothing);
    expect(find.text('33:14', findRichText: true), findsOneWidget);
  });

  testWidgets('SegmentedToggle reports the tapped option', (tester) async {
    int? chosen;
    await tester.pumpInApp(
      Center(
        child: SegmentedToggle<int>(
          options: const [(1, 'one'), (2, 'two')],
          selected: 1,
          onChanged: (value) => chosen = value,
        ),
      ),
    );

    await tester.tap(find.text('two'));
    expect(chosen, 2);
  });
}
