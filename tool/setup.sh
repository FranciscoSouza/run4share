#!/usr/bin/env bash
# One-off setup for the run4share phase-0 project.
# Run from the project root:  bash tool/setup.sh
# Safe to run again: every step skips work that is already done.
set -euo pipefail

cd "$(dirname "$0")/.."
echo "== run4share setup in $(pwd)"
flutter --version

# 1. Fonts (SIL Open Font License, bundled with the app)
FONTS=assets/fonts
mkdir -p "$FONTS"
GF=https://raw.githubusercontent.com/google/fonts/main/ofl/barlowcondensed
for f in SemiBold Bold ExtraBoldItalic; do
  out="$FONTS/BarlowCondensed-$f.ttf"
  [ -s "$out" ] || curl -fsSL -o "$out" "$GF/BarlowCondensed-$f.ttf"
done
curl -fsSL -o "$FONTS/OFL-BarlowCondensed.txt" "$GF/OFL.txt" || true

if [ ! -s "$FONTS/Inter-SemiBold.ttf" ]; then
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/inter.zip" \
    https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
  unzip -q -o "$tmp/inter.zip" -d "$tmp/inter"
  for f in Regular Medium SemiBold; do
    src=$(find "$tmp/inter" -name "Inter-$f.ttf" | head -1)
    cp "$src" "$FONTS/Inter-$f.ttf"
  done
  lic=$(find "$tmp/inter" -name "LICENSE.txt" | head -1)
  [ -n "$lic" ] && cp "$lic" "$FONTS/OFL-Inter.txt"
  rm -rf "$tmp"
fi
ls -l "$FONTS"

# 2. Platform folders (android/ and ios/ only)
if [ ! -d android ] || [ ! -d ios ]; then
  flutter create --platforms android,ios --org com.run4share \
    --project-name run4share .
  # flutter create adds a counter-app test; ours lives in test/app_test.dart
  rm -f test/widget_test.dart
  sed -i '' 's/applicationId = "com.run4share.run4share"/applicationId = "com.run4share.app"/' android/app/build.gradle.kts
  sed -i '' 's/PRODUCT_BUNDLE_IDENTIFIER = com\.run4share\.run4share/PRODUCT_BUNDLE_IDENTIFIER = com.run4share.app/' ios/Runner.xcodeproj/project.pbxproj
fi

# 3. Packages, resolved for this Flutter SDK (each added only once)
add() { grep -q "^  $1:" pubspec.yaml || flutter pub add "$2"; }
add flutter_riverpod flutter_riverpod
add go_router go_router
add flutter_localizations 'flutter_localizations:{"sdk":"flutter"}'
add intl intl:any
add lucide_icons_flutter lucide_icons_flutter
add dio dio
add flutter_web_auth_2 flutter_web_auth_2
add flutter_secure_storage flutter_secure_storage
add freezed_annotation freezed_annotation
add json_annotation json_annotation
add build_runner dev:build_runner
add freezed dev:freezed
add json_serializable dev:json_serializable
add http_mock_adapter dev:http_mock_adapter
add drift drift
add drift_flutter drift_flutter
add drift_dev dev:drift_dev
add gal gal
add share_plus share_plus
add path_provider path_provider
add path path
add photo_manager photo_manager
add crop_your_image crop_your_image
add image dev:image
add sqlite3 dev:sqlite3
add url_launcher url_launcher
add in_app_review in_app_review
add very_good_analysis dev:very_good_analysis

# 4. Generate localisations and models, then check
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
[ -f config/strava.json ] || cp config/strava.example.json config/strava.json
dart format lib test
flutter analyze
flutter test

echo "== Done. Fill in config/strava.json, plug in the Android phone and run:"
echo "   flutter run --dart-define-from-file=config/strava.json"
