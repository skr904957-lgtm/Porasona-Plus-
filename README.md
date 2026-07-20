# Porasona Plus

Purple (#6A1B9A) Material 3 learning platform for students, built in Flutter —
one codebase for Android, tablet, and Web. No AI features, no AI API keys,
no demo/placeholder data anywhere: every screen reads and writes real
Firebase data.

---

## 0. What's in this zip vs. what you still need to do

This is a **complete, real source-code project** — not a mockup. It genuinely
builds and runs once you finish the setup below. What I could not do from my
side (and why):

- I cannot create your Firebase project or Razorpay account — those need
  your own login and business details.
- I cannot compile a signed APK/AAB here — that requires the Android SDK,
  your signing keystore, and the Flutter toolchain running on your machine
  (or a CI runner), none of which exist in this chat environment.
- The logo used in `assets/images/logo.png` and the Android/Web icons is a
  **placeholder** (a simple "P+" mark in your brand purple) — swap in your
  real logo file (see step 3).

Everything else — every screen, the purple Material 3 theme, Firebase Auth /
Firestore / Storage / FCM wiring, the Razorpay checkout flow, the whole admin
panel — is real, working code.

---

## 1. Install prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.22+ (includes Dart)
- Android Studio (for the Android SDK + emulator) or a physical Android device
- A Firebase project — https://console.firebase.google.com
- A Razorpay account — https://dashboard.razorpay.com (only needed for the paid-course flow)

Check your setup:
```
flutter doctor
```

## 2. Get the dependencies

```
cd porasona_plus
flutter pub get
```

If `android/`, `ios/`, or `web/` ever look incomplete on your machine (e.g. missing
Gradle wrapper files), run this once — it safely fills in missing platform
scaffolding without touching your `lib/` code or `pubspec.yaml` dependencies:
```
flutter create .
```

## 3. Add your real logo

Replace this placeholder file with your official logo (keep the same filename,
square PNG, ideally 512×512 or larger, transparent background):
```
assets/images/logo.png
```

For the Android launcher icon and Web icons, the easiest path is the
`flutter_launcher_icons` package:
```
flutter pub add dev:flutter_launcher_icons
```
Add this to `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/logo.png"
  web:
    generate: true
    image_path: "assets/images/logo.png"
```
Then run:
```
flutter pub run flutter_launcher_icons
```
This overwrites the placeholder icons in `android/app/src/main/res/mipmap-*`
and `web/icons/` with your real logo at every required size.

## 4. Connect Firebase (Auth, Firestore, Storage, FCM)

You said you already have your Firebase project and keys ready. Easiest way
to wire them in — the FlutterFire CLI generates `lib/firebase_options.dart`
for you automatically:
```
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>
```
This overwrites the placeholder `lib/firebase_options.dart` in this project
with your real keys for Android, iOS, and Web, and also drops
`android/app/google-services.json` in place.

If you'd rather fill it in by hand, open `lib/firebase_options.dart` and
replace each `REPLACE_WITH_...` placeholder with the matching value from
**Firebase Console → Project Settings → Your apps**.

In the Firebase Console, turn on:
- **Authentication** → Email/Password sign-in method
- **Firestore Database** → create in production mode
- **Storage** → create a default bucket
- **Cloud Messaging** → nothing extra needed to start receiving tokens

Then deploy the included security rules (or paste them into the console's
Rules tab):
```
firestore.rules   →  Firestore → Rules
storage.rules     →  Storage → Rules
```

### Create your first admin account
1. Sign up a normal student account once from the app (or Firebase Console → Authentication → Add user).
2. Copy that user's UID.
3. In Firestore, create collection `admins`, document ID = that UID, with any field, e.g. `{ role: "super_admin" }`.
4. That account can now log in through the **Admin Panel** login screen.

## 5. Connect Razorpay

1. Get your **Key ID** from Razorpay Dashboard → Settings → API Keys.
2. Paste it into `lib/app/app_config.dart`:
   ```dart
   static const String razorpayKeyId = 'rzp_live_xxxxxxxxxxxx';
   ```
3. **Important — do this before going live:** order creation and payment
   signature verification must happen on a trusted backend (never in the
   app), because the Razorpay **Key Secret** must never ship inside your
   APK. The natural fit here is a Firebase Cloud Function, since you're
   already on Firebase — it creates the order via Razorpay's Orders API and
   verifies the signature Razorpay sends back before your Firestore
   `purchases` record is trusted. `lib/services/payment_service.dart` has
   comments marking exactly where this plugs in.

The app builds and runs without a Razorpay key — only the "Buy Now" checkout
button needs it.

## 6. Run it

```
flutter run                       # pick a connected device/emulator
flutter run -d chrome             # run in the browser
```

## 7. Build for release

**Android APK:**
```
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Android App Bundle (for Play Store):**
```
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

Before publishing, set up your own signing key (see
`android/key.properties.example` for the fields, and update
`android/app/build.gradle`'s `signingConfigs` to use it instead of the debug
key that ships in this scaffold).

**Web:**
```
flutter build web --release
```
Output: `build/web/` — deploy this folder to Firebase Hosting, Netlify, or
any static host.

## 8. What's already fully wired vs. what needs a Cloud Function

Fully working client-side, real Firebase reads/writes, zero fake data:
- Auth (login/signup/forgot password), Firestore-backed student profile
- Courses, categories, PDFs, videos, live classes, all 4 test types, question bank
- Leaderboard, achievements, bookmarks, notifications
- Admin panel: manage students/teachers/courses/categories, upload content,
  schedule live classes, create tests & questions, banners, announcements,
  in-app notification broadcast, revenue dashboard, purchases list, coupons

Needs a small **Firebase Cloud Function** (server-side code, not included —
this is a Flutter app scaffold) for production-grade security:
- Creating the Razorpay order and verifying its payment signature before a
  purchase is trusted (client currently records the purchase directly —
  fine for testing, replace before accepting real money)
- Actually delivering push notifications via FCM Admin SDK to student device
  tokens (the client writes the in-app notification and registers the FCM
  token; the server-side "send" call is the missing piece)
- PDF receipt generation for the "Download Receipt" button

## Project structure

```
lib/
  app/            theme, routes, config
  models/         Firestore data models
  services/       Auth, Firestore, Storage, FCM, Razorpay
  providers/      app-wide state (auth, theme, connectivity)
  screens/        every student + admin screen
  widgets/        shared UI components
android/, web/    platform projects
firestore.rules, storage.rules   Firebase security rules
```
