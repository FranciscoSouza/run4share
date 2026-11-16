# run4share release checklist

Steps that need Francisco's accounts or decisions, in order. Code-side
release work is done in phase 7; this is what remains.

## 1. Merge to main

Open the pull requests in order and merge each once CI is green:
phase-1-strava, phase-2-activities, phase-3-photo, phase-4a-editor,
phase-4b-controls, phase-5-share, phase-6-settings, phase-7-release.
The Settings privacy link points to `docs/privacy-policy.md` on `main`,
so it only works after this.

## 2. Keys and secrets (back these up now)

- `~/.run4share/run4share-upload.jks` and `~/.run4share/key.properties.backup`
  (password inside). Put both in your password manager. They are the
  upload key for Google Play; Play re-signs the app, and a lost upload key
  can be reset through Play support, but that takes days.
- `android/key.properties` points the build at that key. It is gitignored.

## 3. Privacy policy

- Review `docs/privacy-policy.md`; fill in `[DATE]` and the contact line.
  It is a draft, not legal advice: have it checked for the GDPR (EU) and
  LGPD (Brazil) if you can.
- Host it on a stable public URL (GitHub Pages is fine) and put that URL
  in `lib/app/links.dart` (`privacyPolicy`). Stores and Strava need it.

## 4. Strava

- When API access is available again: in the Strava API app settings set
  **Authorization Callback Domain** to `localhost`.
- Install Node.js, then deploy the token Worker:
  `server/strava-token/README.md` (wrangler login, two secrets, deploy).
- Put the client ID and Worker URL in `config/strava.json`.
- New Strava apps are limited to a small number of athletes. Apply for
  production access from the API settings page; Strava reviews brand use
  (the app uses the official Connect button and "Powered by Strava") and
  the privacy policy.

## 5. Google Play Console

1. Create a developer account (one-time US$ 25) and a payments profile.
2. Create the app: name **run4share**, default language, App, Free.
3. Build and upload to **Internal testing**:
   `flutter build appbundle --release --dart-define-from-file=config/strava.json`
   then upload `build/app/outputs/bundle/release/app-release.aab`.
   Accept Play App Signing. Add your Google account as a tester.
4. **Pro product**: Monetize > Products > In-app products > Create:
   - Product ID: `run4share_pro` (must match `lib/features/pro/pro_store.dart`)
   - Name: run4share Pro. Description: No watermark and every new theme.
   - Price: US$ 2.99 (accept Play's local prices). Activate.
   - Settings > License testing: add your account to buy for free.
   Install from the internal testing link: the Pro screen then shows the
   real price and the purchase works.
5. **Store listing**: short and full description, phone screenshots (the
   design artboards are a good guide), 512 px icon
   (`assets/icon/icon.png` scaled down), feature graphic 1024 x 500.
6. **App content**:
   - Privacy policy URL (step 3).
   - Ads: no.
   - Data safety: answer from the privacy policy. As built, run4share
     collects no data on its servers; activities, photos and images stay
     on the phone. The Strava sign-in code passes through the Worker only
     to be exchanged and is not stored. Review Google's definitions of
     "collected" and "ephemeral processing" before answering.
   - Target audience: 13+. Content rating questionnaire.
   - **Health Connect**: App content > Health apps, and the Health
     Connect permissions declaration. Declare each read permission with
     why it's needed (workouts, distance, calories, heart rate, routes,
     past data, all to make images of the user's own workouts). Google
     reviews this; the privacy policy must describe it (it does).
7. Promote internal testing > closed testing > production when ready.

## 6. iOS (on the Mac)

- Open `ios/Runner.xcworkspace` in Xcode, set the signing team; bundle ID
  is `com.run4share.app`.
- App Store Connect: create the app and an in-app purchase,
  Non-Consumable, product ID `run4share_pro`, same price tier.
- `flutter build ipa --dart-define-from-file=config/strava.json`, upload
  with Xcode or Transporter, test through TestFlight.
- Apple Developer Program membership (paid) is needed for HealthKit on a
  device: set the Team in Xcode; the HealthKit capability is already in
  `Runner/Runner.entitlements`. App Store Connect asks about health data
  use in App Privacy; answer from the privacy policy.
- Permission texts are translated (`ios/Runner/*.lproj/InfoPlist.strings`).

## 7. Every release

- Bump `version:` in `pubspec.yaml` and `AppInfo.version`
  (`lib/app/app_info.dart`); a test fails if they differ.
- Run `bash tool/setup.sh` (analyze + tests) and check CI is green.
- Laboratory is hidden in release builds; check it is gone.
- Translations: `python3 tool/translations.py export` for reviewers,
  `import` to apply their fixes.
