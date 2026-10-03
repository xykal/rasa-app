# 🛠️ SETUP RASA — Dari Nol Sampai Production

Panduan lengkap: demo → Firebase → Gemini → release → GitHub Secrets.

---

## 1. Syarat

- Flutter 3.22+ (`flutter doctor` hijau)
- Akun Google (buat Firebase + Gemini)
- Java 17 (buat build Android)

## 2. Jalanin Demo (Tanpa Config Apa Pun)

```bash
flutter create . --project-name rasa --org com.rasa.app
flutter pub get
flutter run
```

Berhasil kalau: muncul onboarding ungu → pilih mood → feed rame data dummy.

## 3. Setup Firebase (Mode Production)

1. Buka [Firebase Console](https://console.firebase.google.com) → Add project `rasa-app`.
2. **Android app:** package `com.rasa.app` → download `google-services.json` → taruh di `android/app/`.
3. **Authentication** → Sign-in method → aktifkan **Anonymous**.
4. **Firestore Database** → Create database (production mode, region `asia-southeast2` biar dekat 🇮🇩).
5. Tab **Rules** → copy-paste isi `firestore.rules` → Publish.
6. (Opsional) **Cloud Messaging** → buat notifikasi "ada yang memeluk curhatmu" (template di bawah).

### Skema Koleksi

```
users/{uid}            { alias, streak, createdAt }
posts/{postId}         { text, mood, authorId, alias, createdAt,
                         hugCount, meTooCount, replyCount, aiReply }
posts/{postId}/replies/{replyId}  { text, alias, authorId, createdAt, isAI }
reports/{reportId}     { postId, reason, reporterId, createdAt }  (khusus admin)
```

Jalanin production lokal:

```bash
flutter run --dart-define=DEMO_MODE=false
```

> Di HP: buka Profil → matikan toggle "Mode Demo" → restart app.

## 4. Aktifin Gemini AI (Biar Pinter Beneran)

1. Buka [Google AI Studio](https://aistudio.google.com) → Get API key (gratis, ada kuota harian).
2. Jalanin/build dengan key:

```bash
flutter run --dart-define=DEMO_MODE=false --dart-define=GEMINI_KEY=AIza...
```

Model yang dipakai: `gemini-1.5-flash` (cepat + murah). Ganti di `lib/data/services/gemini_service.dart` kalau mau.

**Tanpa key pun app tetap jalan** — otomatis pakai 5 balasan empati bawaan + chat rule-based. Jadi buyer bisa demo gratis dulu.

## 5. Build Release (APK + AAB Play Store)

```bash
# 1. Bikin keystore (sekali saja, SIMPAN BAIK-BAIK)
keytool -genkey -v -keystore ~/rasa-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rasa

# 2. Isi android/key.properties (JANGAN commit! sudah di .gitignore)
# storePassword=xxx
# keyPassword=xxx
# keyAlias=rasa
# storeFile=/home/kamu/rasa-upload.jks

# 3. Build
flutter build apk --release --dart-define=DEMO_MODE=false --dart-define=GEMINI_KEY=AIza...
flutter build appbundle --release --dart-define=DEMO_MODE=false --dart-define=GEMINI_KEY=AIza...
```

Catatan: `flutter create` versi baru kadang belum wiring `key.properties`. Kalau release build gagal signing, tambahkan blok standar `keystoreProperties` di `android/app/build.gradle(.kts)` — template resmi ada di dokumentasi Flutter ("Sign the app").

## 6. GitHub Secrets (Build Otomatis Signed)

Biar tiap push ke `main` menghasilkan APK release signed otomatis:

| Secret / Variable | Isi | Cara bikin |
|---|---|---|
| `ANDROID_GOOGLE_SERVICES` | base64 dari `google-services.json` | `base64 -w0 android/app/google-services.json` |
| `GEMINI_KEY` | API key Gemini | paste biasa |
| `KEYSTORE_BASE64` | base64 file `.jks` | `base64 -w0 ~/rasa-upload.jks` |
| `KEYSTORE_PASSWORD` | password keystore | paste biasa |
| `KEY_PASSWORD` | password key | paste biasa |
| `KEY_ALIAS` | alias key | misal `rasa` |
| Variable `ENABLE_RELEASE` | `true` | Settings → Secrets → Variables → New |

Isi di: repo GitHub → **Settings → Secrets and variables → Actions**.

APK debug (demo) **selalu ke-build otomatis tanpa secret apa pun** — jadi tombol Actions ijo dari hari pertama. Job release baru jalan kalau `ENABLE_RELEASE=true`.

## 7. Upgrade Biliar Chat ke Matchmaking Real (Roadmap)

MVP sekarang pakai simulasi bot (biar bisa demo 1 HP). Buat real 2-user:

1. Koleksi `queue/{uid}`: `{ alias, joinedAt }` — user join saat tekan "Cari".
2. Cloud Function / client listener: kalau ada 2 dokumen di queue → buat `rooms/{roomId}` berisi `members: [uid1, uid2]`, hapus dari queue.
3. Sub-koleksi `rooms/{roomId}/messages` untuk chat real-time + `endsAt` (now + 5 menit).
4. Security rules: hanya member yang bisa baca/tulis room-nya.

Estimasi: 1–2 hari kerja. Struktur `roomId` sudah disiapkan komentarnya di `biliar_chat_screen.dart`.

## 8. Notifikasi "Ada yang memelukmu 🫂" (Opsional, +Nilai Jual)

Termudah: Cloud Function trigger `onUpdate` di `posts` — kalau `hugCount` naik → kirim FCM ke `authorId`. Butuh simpan FCM token di `users/{uid}.fcmToken` (tambah 10 baris di `SessionNotifier`, paket `firebase_messaging` sudah ada di pubspec).

## 9. Troubleshooting

| Gejala | Solusi |
|---|---|
| `google-services.json` missing saat build lokal | Normal — app jalan demo mode. Atau generate dummy: lihat workflow `build-apk.yml`. |
| Feed kosong di production | Cek Firestore rules sudah Publish + Anonymous Auth aktif. |
| AI selalu balasan bawaan | Cek `GEMINI_KEY` kepassing (`--dart-define`), cek kuota AI Studio. |
| `flutter create` menimpa file saya | Aman — dia cuma generate folder platform, `lib/` tidak disentuh. |
| Error `IdMessages` / timeago | `flutter pub get` ulang; butuh timeago ≥ 3.0. |
