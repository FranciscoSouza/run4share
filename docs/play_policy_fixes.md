# Play policy fixes before the first upload: instructions for Claude Code

_18 Nov 2026 · against commit `609fb74`_

Read `CLAUDE.md` first. Two changes Google Play requires before run4share can be published, plus checks. Work on a branch, `phase-20-play-policy`.

## 1. Use the system photo picker; drop READ_MEDIA_IMAGES

**Why:** Google Play's Photo and Video Permissions policy only allows `READ_MEDIA_IMAGES` when the system photo picker isn't enough for the app's core purpose. run4share picks one photo per image, so the picker is enough. Keeping the permission means a Play Console declaration that is likely to be refused.

**Change:**
- Replace the in-app photo grid (`lib/features/photos/`, `photo_manager`) with the system picker through `image_picker`:
  - Android: Android Photo Picker, no permission needed, backported to older Android through Google Play services.
  - iPhone: PHPicker, no library permission needed.
- Keep `PhotoLibrary` as the interface so tests still use a fake; its new implementation calls the picker.
- **Copy the picked image into the app's storage** (`<app documents>/photos/<uuid>.jpg`, full resolution, EXIF orientation applied). Use that file's id as `CreationDraft.photoId`.
  - The crop step, export at full resolution and "Edit again" from My Creations then keep working without library access.
  - When a creation is deleted, delete its photo copy if no other creation uses it. Run a one-off clean-up of unreferenced copies at start-up.
- **Existing drafts and creations** saved with `photo_manager` asset ids:
  - try to load them once through `photo_manager` only if it is still present;
  - otherwise treat them like a missing photo. The current "the original photo is gone" message for Edit already covers this.
  - Simplest is to remove `photo_manager` entirely and accept that pre-release creations can't be edited again. Ask Francisco which he prefers (nobody outside testing has data yet).
- **Remove** from `android/app/src/main/AndroidManifest.xml`: `READ_MEDIA_IMAGES` and `READ_MEDIA_VISUAL_USER_SELECTED`.
  - Keep `WRITE_EXTERNAL_STORAGE` with `maxSdkVersion="28"` (saving with `gal` on Android 9 and older).
  - iOS: keep `NSPhotoLibraryAddUsageDescription` (saving). Remove `NSPhotoLibraryUsageDescription` only if nothing else reads the library.
- Screens:
  - The photo step becomes "tap → system picker opens". Remove the "Photo access" explainer and "Photo access is off" screens on both platforms; the picker needs no permission.
  - Remove Settings › Photo access, and their strings in all five ARB files.
- Strava activity photos on cards (phase 19) come from the network and are unaffected.

**Tests:** update the photo tests to the new `PhotoLibrary`. Add tests for: copy on pick; the photo id survives a restart; a deleted creation removes an unreferenced copy; an old asset id gets the missing-photo path.

## 2. Target Android 16 (API 36), explicitly

In `android/app/build.gradle.kts` set `compileSdk = 36` and `targetSdk = 36` (don't rely on `flutter.targetSdkVersion`).
- Check that the `health`, `in_app_purchase`, `gal` and `flutter_web_auth_2` plugins build against 36.
- Run the app on the Galaxy S22 (Android 16) and check edge-to-edge (status and navigation bars) on Home, the editor and onboarding.

## 3. Checks on the release bundle

After `flutter build appbundle --release --dart-define-from-file=config/strava.json`:
- Merged manifest (`build/app/intermediates/merged_manifest/release/.../AndroidManifest.xml`, or `bundletool dump manifest --bundle app-release.aab`):
  - `targetSdkVersion="36"`;
  - **no** `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` or `com.google.android.gms.permission.AD_ID`. If a plugin adds `AD_ID`, remove it with `tools:node="remove"`.
- `versionCode 1`, `versionName 1.0.0`.
- Laboratory hidden; no debug banner; the signing certificate SHA-256 matches the upload key in `docs/release-checklist.md`.

## 4. Docs

- `docs/privacy-policy.md`: photos are chosen with the system picker and a copy is kept in the app only to edit the image again.
- `CLAUDE.md`: add a **Phase 20 status (Play policy)** block.

## Check-points on Francisco's phone

1. Pick a photo: the system picker opens with no permission prompt, and the crop and editor work.
2. Close and reopen the app, then Edit again from My Creations: the photo is still there.
3. Save to Photos and share still work.
4. Settings no longer shows Photo access.
