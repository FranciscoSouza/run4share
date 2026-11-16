import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/onboarding/onboarding_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A renamed or missing file would show a blank: fail here instead.
  test('every listed template picture is in the bundle', () async {
    expect(templatePhotos, hasLength(storyTemplates.length));
    for (final template in storyTemplates) {
      final photo = template.photo;
      expect(photo, isNotNull, reason: template.id);
      final bytes = await rootBundle.load(photo!);
      expect(bytes.lengthInBytes, greaterThan(10000), reason: photo);
    }
  });

  test('every listed onboarding picture is in the bundle', () async {
    expect(onboardingPhotos, hasLength(4));
    for (final name in onboardingPhotos) {
      final bytes = await rootBundle.load('assets/onboarding/$name');
      expect(bytes.lengthInBytes, greaterThan(10000), reason: name);
    }
  });

  test('a template position overrides its theme only for that template', () {
    final top = templateById('top-line')!;
    expect(top.stickerCenter.dy, lessThan(0.2), reason: 'stats at the top');
    expect(top.theme.position, const Offset(0.5, 0.72), reason: 'theme kept');
    final hero = templateById('story-hero')!;
    expect(hero.stickerCenter, hero.theme.position);
  });
}
