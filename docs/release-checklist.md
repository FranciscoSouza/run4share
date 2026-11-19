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

- Contact and date filled in (20 Nov 2026): **Run4Share,
  run4share.app@gmail.com**, last updated 20 November 2026. It is a
  draft, not legal advice: have it checked for the GDPR (EU) and LGPD
  (Brazil) if you can.
- After editing the Markdown: `python3 tool/policy/build_policy.py`
  rebuilds `docs/privacy/index.html` (the review note stays out of it).
- GitHub Pages is on (Francisco, 20 Nov 2026: `main`, `/docs`). Once
  `docs/privacy/` is on `main`, the policy is at
  **https://franciscosouza.github.io/run4share/privacy/**: the URL for
  Google Play, the Health Connect declaration and Strava's review. The
  app already points there (Settings › Privacy policy opens it in an
  in-app browser tab; Health Connect's "why we ask" link too).
- `docs/` is public with Pages on (it already is, the repo being
  public); `docs/.nojekyll` serves files as they are.

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

## 5. Google Play Console (personal account)

1. **Developer account:** play.google.com/console, one-time US$ 25,
   identity verification (ID document; can take a few days), a payments
   profile for the Pro purchase, and a **public developer email**.
2. **Create the app:** name **run4share**, default language (English),
   App, Free, declarations. Package `com.run4share.app`.
3. **App signing:** upload an AAB and accept Play App Signing; Play signs
   for users, your upload key (`~/.run4share/run4share-upload.jks`) signs
   what you upload.
   `flutter build appbundle --release --dart-define-from-file=config/strava.json`
   → `build/app/outputs/bundle/release/app-release.aab`. Laboratory is
   hidden in this build (it only shows in debug or with `LAB=true`).
4. **Testing tracks, in order** (rule for new personal accounts):
   - *Internal testing*: you, straight away; check the build, Strava,
     Health Connect, Pro (with license testing, below).
   - *Closed testing*: **at least 12 testers opted in for 14 days in a
     row**, before Play lets you apply for production. Collect 12+ Gmail
     addresses (friends, running club), add them as a list, share the
     opt-in link. Keep them opted in for the whole 14 days.
   - Then *Apply for production* (Play asks a few questions about the
     test), and roll out.
5. **Pro product** (Monetize › Products › In-app products):
   - Product ID `run4share_pro` (must match `lib/features/pro/pro_store.dart`),
     non-consumable, price US$ 2.99 (accept local prices), activate.
   - Description: Charts, route styles, Pro themes, templates and
     stickers, photo effects, and no watermark. One payment.
   - Settings › License testing: add your account and testers to buy for
     free.
6. **Store listing:** texts in `docs/store-listing.md` (five languages;
   native review first). Graphics: 512 px icon (`assets/icon/icon.png`
   scaled), feature graphic 1024 × 500, 2-8 phone screenshots (take them
   on the phone; Claude can capture them with adb: Home, editor with a
   theme and a chart, Share with sticker only, My Creations, Pro). Category:
   Health & Fitness. Contact email and the privacy policy URL.
7. **App content** (Policy › App content), answers drafted from what the
   app does:
   - Privacy policy: the GitHub Pages URL above.
   - Ads: no ads.
   - App access: no login needed to review; reviewers can add an
     activity by hand (Strava and Health Connect are optional). Say so.
   - Content rating questionnaire: a utility/fitness app, no user
     content shared through the app, no violence etc.
   - Target audience: 13+ (not designed for children).
   - Data safety: no data collected or shared by the developer;
     activities, photos and images stay on the phone. Strava sign-in
     tokens pass through the token Worker only to be exchanged, not
     stored (Google calls this ephemeral processing; check their
     definitions). What does travel (to Strava, to the token Worker)
     goes over HTTPS. Users can delete everything by disconnecting or
     uninstalling (no account to delete).
   - **Health apps declaration and Health Connect permissions**: declare
     each read permission and why: exercise, exercise routes, distance,
     total and active calories, heart rate, steps, history; all to turn
     the user's own workouts into images. Steps: the health library reads
     them with each workout and returns nothing without them; run4share
     doesn't use or keep them. Google reviews this; the policy describes
     it.
   - Photo permissions: **none**. The app uses Android's system photo
     picker (no READ_MEDIA_IMAGES), so there's no Photo and Video
     Permissions declaration to file.
   - Financial features, government, news, COVID: no.
8. **Pre-launch report**: Play runs the build on test devices after each
   upload; look at crashes and accessibility warnings before production.

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
