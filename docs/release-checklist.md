# run4share release checklist

Steps that need Francisco's accounts or decisions, in order. Code-side
release work was done in phase 7 and reviewed again in phase 18 (16 Nov
2026, against phases 8-17); this is what remains.

## 1. Merge to main: done

16 Nov 2026: `main` fast-forwarded to phase 17 (`e15562c`); the 17 phase
branches were one linear stack, so nothing was rewritten. CI passed on
`main`. The Settings privacy link (`docs/privacy-policy.md` on `main`)
now resolves. Later work: a branch per phase, fast-forward `main` when
Francisco approves it on the phone.

Verified the same day: `flutter build appbundle --release` builds and is
signed with the upload key (SHA-256 `DE:8D:3E:29:…:B0:D7`, matching
`~/.run4share/run4share-upload.jks`).

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

## 3b. Photos and texts only Francisco can supply

- Onboarding: four photos, `assets/onboarding/README.md`.
- Templates: eleven photos and `CREDITS.md`, `assets/templates/README.md`.
  Until then pages and templates show flat colours or gradients, which
  is shippable but plain.
- Translations: `docs/translations-review.csv` has every string from
  phases 8-17 (stickers, phrases, stamps, charts, onboarding, templates,
  effects); have native speakers of pt-BR, es, fr and de check it, then
  `python3 tool/translations.py import`.
- Store listing: drafts in `docs/store-listing.md` (all five languages;
  same review).

## 4. Strava

- When API access is available again: in the Strava API app settings set
  **Authorization Callback Domain** to `localhost`.
- Install Node.js, then deploy the token Worker:
  `server/strava-token/README.md` (wrangler login, two secrets, deploy).
- Put the client ID and Worker URL in `config/strava.json`.
- **Rate limits are per app, shared by every user.** Each activity opened
  in the editor for the first time costs up to three calls (detail,
  streams, gear), plus the list syncs. Check the limits on the API
  settings page and ask Strava for more before launch; when a limit is
  hit the app keeps working, just without the charts/shoe for that
  activity until a later visit.
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
   - Name: run4share Pro. Description: Charts, route styles, Pro themes,
     templates and stickers, photo effects, and no watermark. One payment.
     (Keep it in step with the Pro screen and the onboarding's last page.)
   - Price: US$ 2.99 (accept Play's local prices). Activate.
   - Settings > License testing: add your account to buy for free.
   Install from the internal testing link: the Pro screen then shows the
   real price and the purchase works.
5. **Store listing**: short and full description (drafts in
   `docs/store-listing.md`), phone screenshots (take them on the phone:
   Home carousel, the editor with a theme and a chart, Share with sticker
   only, My Creations, Pro), 512 px icon
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
- App Store review: HealthKit apps must have a privacy policy link in the
  app and on the store page (both point at `docs/privacy-policy.md`), and
  may not use health data for ads (it doesn't). In App Privacy, health
  and fitness data is "not collected" (it stays on the iPhone).
- Not yet run on a real iPhone: copy sticker (UIPasteboard), Apple Health
  connect, photo access. Test them in the first TestFlight build.

## 7. Every release

- Bump `version:` in `pubspec.yaml` and `AppInfo.version`
  (`lib/app/app_info.dart`); a test fails if they differ.
- Run `bash tool/setup.sh` (analyze + tests) and check CI is green.
- Laboratory is hidden in release builds; check it is gone.
- Translations: `python3 tool/translations.py export` for reviewers,
  `import` to apply their fixes.
