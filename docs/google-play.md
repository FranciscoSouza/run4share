# Publishing run4share on Google Play: the complete guide

_18 Nov 2026 · supersedes section 5 of `docs/release-checklist.md` · the store files are in `store/google-play/`_

Everything you set up, upload and answer in Play Console, in order. The answers below describe the app as built at commit `609fb74`. If a feature changes, change the matching answer.

## 0. The timeline, and why it's at least about 3 weeks

| When | What |
|---|---|
| Day 0 | New Google account, Play Console account, identity verification (can take a few days) |
| Day 0–2 | Code changes in section 3 (Claude Code), first upload to **Internal testing** for you |
| Day 2 | Start a **closed test with at least 12 testers** |
| Day 16 | Apply for production access (only possible after 14 days with 12 testers opted in the whole time) |
| Day 16–23 | Google reviews the application, then the production release (up to about 7 days) |

New **personal** accounts must run a closed test with at least 12 testers who stay opted in for 14 days in a row before production unlocks. An **organisation** account skips this, but needs a registered company and a D-U-N-S number. With a new personal account, plan for the 14 days.

## 1. The new Google account

1. Create it with a name you're happy to keep, for example `run4share.app@gmail.com`. Turn on 2-step verification and add a recovery phone and email.
2. Use this account to own Play Console. After step 2, add your personal account as an **Admin** user (Users and permissions), so you're never locked out.
3. Use this account (or a support alias) as the public **contact email** on the store page and in `docs/privacy-policy.md`.

## 2. Play Console developer account

1. Go to play.google.com/console with the new account. Choose **Personal** (unless you have a company) and pay the one-time US$25.
2. **Identity verification:** legal name, address, phone and a photo of an ID document. The **developer name** shown on Play can be `run4share`.
3. **Android developer verification:** Google now links every app to a verified developer, enforced first in **Brazil** (since 30 Sep 2026), then worldwide in 2027. Completing Play Console's verification covers this, and Play apps are registered for you automatically. Check *Android developer verification* in Console for a green tick.
4. **EU trader status (Digital Services Act):** because you sell an in-app purchase, you are a "trader". Play shows a trader's address, phone and email to EU users. If you don't want your home address public, use a business or virtual-office address.
5. **Payments profile** (needed to sell Pro): Setup › Payments profile. Add a UK bank account and your UK tax details. Google pays out monthly.

## 3. Code changes before the first upload (Claude Code)

Run this in Claude Code from the run4share folder:

```
Read CLAUDE.md and docs/play_policy_fixes.md and make those changes. Ask me before assuming anything not in the doc.
```

There are two must-fixes (details in `docs/play_policy_fixes.md`):
- **Photo permission:** the app asks for `READ_MEDIA_IMAGES` (full photo library). Google now allows that only when the system photo picker can't do the job, and run4share only needs one photo at a time. Keeping it means a declaration that is likely to be rejected. The fix is to use the Android photo picker and remove the permission.
- **Target SDK:** new apps must target **Android 16 (API 36)**. Make it explicit in `android/app/build.gradle.kts` and check it in the built bundle.

Then bump nothing: `1.0.0+1` is right for the first upload. Every later upload needs a higher build number (`1.0.0+2` and so on).

## 4. Create the app and the main store listing

**Create app:** name `run4share` · default language **English (United States)** · App · Free · accept the declarations.

**Store settings › App category:** **Health & Fitness**. Tags: Running, Cycling, Photography, Social. Contact email from section 1. Website: your GitHub Pages site, or leave empty.

**Main store listing:** all files are ready in `store/google-play/metadata/android/<language>/`, laid out the way the `fastlane supply` upload tool expects, in case you automate it later.

| Field | File | Limit | Status |
|---|---|---|---|
| App name | `title.txt` | 30 | ready (`run4share`) |
| Short description | `short_description.txt` | 80 | ready, 75–80 chars |
| Full description | `full_description.txt` | 4,000 | ready, about 1,100–1,300 chars |
| App icon | `images/icon.png` | 512×512, 32-bit PNG, ≤1 MB | ready |
| Feature graphic | `images/featureGraphic.png` | 1024×500, no transparency | ready, tagline in each language |
| Phone screenshots | `images/phoneScreenshots/1–6.png` | 2–8, 9:16, ≥1080 px for best placement | **drafts**; replace with real captures (section 5) |

Languages: **en-US** (default), **pt-BR**, **es-ES**, **fr-FR**, **de-DE**. Add each one under *Manage translations › Add your own translations* and paste its files.
- If you want Latin America too, add **es-419** with the same Spanish files.
- The listing texts still need the native-speaker review mentioned in `docs/store-listing.md`.

## 5. Screenshots: real captures from your phone

The drafts in the folder use design images: they show the look, not the shipped app. Google expects screenshots of the real app, so capture 6 screens on the Galaxy S22 per language. Use Laboratory › Strava demo data so the activities look good, and add Francisco's own photo for the editor shots.

| # | Screen | Caption (en) |
|---|---|---|
| 1 | Home with the templates carousel | Make posts like these |
| 2 | Editor, a photo with the Inline Top theme | Your photo. Your stats. |
| 3 | Editor, the sticker selected (handles showing) | Every stat, your way |
| 4 | Editor with a Pro chart sticker (pace or heart rate) on the photo | Charts from your real data |
| 5 | Share screen with Sticker only on | Share to Stories, or just the sticker |
| 6 | Pro screen | Pay once. Keep it forever. |

How to capture:
1. Plug the phone in. With Developer options › USB debugging on, run for each screen:
   `adb exec-out screencap -p > store/google-play/captures/en-US/1.png`
   (or take normal screenshots and copy them across).
2. Switch the app's language (Settings › Language) and repeat into `captures/pt-BR/`, `es-ES/`, `fr-FR/` and `de-DE/`. A language without captures falls back to the English captures.
3. Run `pip3 install pillow` (once), then:
   `python3 tool/store/make_play_assets.py --shots store/google-play/captures`
   This rewrites the icon, the feature graphics and the framed, captioned screenshots for all five languages.
4. Hide the clock and battery clutter if you like: Developer options › System UI demo mode.

## 6. App content: every questionnaire and its answer

**Privacy policy:** the public URL of `docs/privacy-policy.md`, served through GitHub Pages so it's a normal web page. Fill in `[DATE]` and the contact first.

**App access:** "All functionality is available without special access."
- Instructions for reviewers: *No sign-in is needed. Tap + on Home to add an activity by hand, then pick any photo. Strava and Health Connect are optional sources. Pro is an in-app purchase; nothing is locked behind an account.*

**Ads:** No, the app contains no ads.

**Content rating (IARC questionnaire):**
- Category: *All other app types*.
- Violence, sexuality, language, controlled substances, gambling: **No** to all.
- Users interact or share with each other inside the app: **No** (images are shared through the system share sheet, outside the app).
- Shares the user's location with others: **No** (routes are drawn in images the user chooses to share, never sent by the app).
- Digital purchases: **Yes**.

The expected result is Everyone / PEGI 3.

**Target audience:** **13 and over** (13–15, 16–17, 18+). Not designed for children; don't opt into the Families programme.

**Data safety** (read Google's definitions as you go; these follow how the app works):
- Does the app collect or share any of the required user data types? **Yes**, because of the Strava sign-in:
  - When someone connects Strava, the sign-in code goes to your token Worker and Strava's reply (the access token and the athlete's **name and ID**) comes back through it. Nothing is stored.
  - Declare **Personal info › Name** and **Personal info › User IDs**. For both: collected, **processed ephemerally**, **not shared**, **optional** (only when connecting Strava), purpose **App functionality**.
  - **App info and performance** (crash logs, diagnostics): none; the app has no crash reporting.
  - Simpler alternative: have the Worker strip the athlete object from its reply. Then nothing personal passes through your server.
- **Photos, health and fitness data, activities, routes:** read and processed **on the device only**, never sent to you. Under Google's definitions that is **not collected**.
- **Purchases:** handled by Google Play Billing; the app has no server that receives them, so they're not collected by you.
- Encrypted in transit: **Yes** (HTTPS only).
- Way to request data deletion: you keep no user data. State that, and note that disconnecting Strava or Health Connect deletes the synced activities from the phone.
- No data used for ads, analytics or tracking.

**Health apps declaration:** select *Health and fitness › Activity and fitness tracking: reads workouts to create images*. The app is not a medical device.

**Health Connect permissions** (Policy › App content › Health Connect). Give a reason for each permission:

| Permission | Reason to paste |
|---|---|
| READ_EXERCISE | Lists the user's workouts so they can pick one to turn into an image. |
| READ_EXERCISE_ROUTES | Draws the workout's route as a sticker on the user's image. |
| READ_DISTANCE | Shows the workout's distance and pace on the image. |
| READ_TOTAL_CALORIES_BURNED, READ_ACTIVE_CALORIES_BURNED | Shows calories on the image when the user picks a theme that includes them. |
| READ_HEART_RATE | Shows average heart rate and the heart-rate chart sticker. |
| READ_STEPS | The health library returns workouts only together with their step data; steps are not shown or stored separately. |
| READ_HEALTH_DATA_HISTORY | Lets users make images of workouts older than 30 days. |

Add this line to every reason: *Data is read on the device only, never uploaded, never used for ads.* Google may ask for a short screen recording of the Health Connect flow: connect → workout list → image with route and heart rate.

**Photo and video permissions:** nothing to declare once section 3 is done (no `READ_MEDIA_IMAGES`). If you keep the permission instead, Console forces a declaration. Write: *run4share's core purpose is turning the user's own photos into workout images; users browse their recent photos repeatedly while creating*. Expect it may be refused.

**Advertising ID:** No. After building, check that `com.google.android.gms.permission.AD_ID` isn't in the merged manifest (see `docs/play_policy_fixes.md`).

**Financial features, Government app, News, COVID, Data deletion via web:** No / not applicable.

## 7. Monetisation: the Pro product

1. Monetize › Products › **In-app products** › Create. This only appears after a bundle that includes the billing library is uploaded (section 8, step 1).
   - Product ID: `run4share_pro` (must match `lib/features/pro/pro_store.dart`).
   - Name: *run4share Pro*. Description: *Charts, route styles, Pro themes, templates and stickers, photo effects, and no watermark. One payment.*
   - Price: £2.49 / US$2.99 (let Play set local prices) › **Activate**.
2. Setup › **License testing:** add your accounts and your 12 testers' accounts, so they can buy Pro for free in test builds.

## 8. Testing tracks

1. **Internal testing** (instant, up to 100 people):
   - Build with `flutter build appbundle --release --dart-define-from-file=config/strava.json`.
   - Upload `build/app/outputs/bundle/release/app-release.aab` and accept **Play App Signing**. Your upload key stays `~/.run4share/run4share-upload.jks`; back it up.
   - Release name `1.0.0 (1)`; release notes from `changelogs/1.txt`.
   - Add yourself, install from the opt-in link, buy Pro with the license tester and check that the real price shows.
2. **Closed testing**, the 14-day clock:
   - Create a track named "Beta". Add the testers as a **Google Group** (easier to manage than a list of emails) and choose all countries.
   - Send the opt-in link. Each tester must tap **Become a tester** and install from Play, not from a file.
   - Keep **at least 12 opted in for 14 days straight**. Invite about 15, so one or two dropping out doesn't reset the clock.
   - Ship one or two updates during the test (`1.0.0+2`, `+3`) and collect feedback. Google asks about this afterwards.
3. **Apply for production** (Dashboard › Apply for production). Draft answers:
   - *How did you recruit testers?* Friends and running-club members who use Strava; about 15 invited.
   - *How easy was it to get feedback?* A form in the app (Settings › Send feedback) and a WhatsApp group.
   - *What did you change?* Name the fixes from the test updates.
   - *Who is the app for?* Runners, cyclists and hikers who share workouts on Instagram.
   - *What makes it ready?* Tested on Android 13–16 phones, both sources, the purchase flow and 5 languages.

## 9. Production release

1. Production › Create release, promoting the build already tested in closed testing.
2. **Countries:** all, or start with UK, Brazil, Portugal, Spain, France and Germany.
3. **Staged rollout:** 20 % → 50 % → 100 % over a week, watching *Android vitals* (crashes, ANRs).
4. Release notes: `changelogs/1.txt` per language (≤500 chars, ready).

## 10. Every later release

- `pubspec.yaml`: bump `version: 1.0.1+2`, and `AppInfo.version` (a test checks they match).
- Add `changelogs/<build number>.txt` per language.
- Upload to internal testing → check → promote to production (no more 14-day wait after the first approval).
