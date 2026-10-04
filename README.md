# 💜 RASA — Anonymous Curhat + AI Teman Healing

> Curhat anonim, ditemenin AI & sesama manusia.

Aplikasi social-healing: user curhat 100% anonim → langsung dibalas **AI empati (Gemini)** → ditemenin komunitas via Peluk/Sama/balasan → dilengkapi **AI Chat 1-on-1**, **Biliar Chat random**, **streak harian**, dan **pertanyaan harian**.

**Tech:** Flutter + Riverpod + Firebase (Auth, Firestore, FCM) + Gemini AI.

---

## ✨ Fitur

| Fitur | Keterangan |
|---|---|
| 🎭 Onboarding anonim | Nama samaran random + mood check-in, tanpa daftar ribet |
| 🌙 Feed curhat | Filter mood, pull-to-refresh, badge "AI nemenin" |
| ✨ AI reply otomatis | Tiap postingan baru langsung dibalas Gemini AI (< 5 detik) |
| 🫂 Peluk & Sama | Reaksi hangat khas komunitas support |
| 💬 Balasan & lapor | Thread balasan + bottom-sheet lapor konten toxic |
| 🤖 AI Teman Chat | Chat bebas 1-on-1, ada saran cepat + mode hemat offline |
| 🎲 Biliar Chat | Ngobrol random anonim 5 menit (MVP simulasi, siap upgrade matchmaking) |
| 🔥 Streak & profil | Streak harian, statistik peluk, riwayat curhat sendiri |
| 🛡️ Moderasi | Filter kata kasar client-side + `firestore.rules` + koleksi `reports` |
| 📦 Demo mode | **Langsung jalan tanpa Firebase** — cocok buat review buyer |
| 🔍 Pencarian | Cari cerita / nama samaran langsung dari feed |
| 🌓 Tema | Terang / Gelap / Auto, tersimpan otomatis |
| 🗑️ Kelola konten | Hapus cerita & tanggapan milik sendiri |
| 👋 Splash screen | Branding saat aplikasi dimuat |
| 🔔 Notifikasi | OneSignal push — klik notif langsung buka cerita |

## 🚀 Coba 2 Menit (Tanpa Firebase)

```bash
# 1. Install Flutter 3.22+ (https://docs.flutter.dev/get-started/install)
# 2. Generate folder platform (sekali saja):
flutter create . --project-name rasa --org com.rasa.app

# 3. Jalanin (default DEMO_MODE=true → data dummy lokal):
flutter pub get
flutter run
```

> Semua fitur bisa diklik & dicoba dalam demo mode. AI pakai balasan bawaan
> yang hangat; isi `GEMINI_KEY` biar jadi AI beneran (lihat `SETUP.md`).

## 🏗️ Build APK via GitHub (Otomatis)

1. Push repo ini ke GitHub.
2. Buka tab **Actions** → workflow **Build APK** jalan otomatis.
3. Download APK di **Artifacts → rasa-debug-apk**.

Tanpa setup apa pun, build demo tetap lolos (pakai `google-services.json` dummy).
Untuk production (Firebase asli + release signed): lihat `SETUP.md` bagian Secrets.

## 📁 Struktur Folder

```
lib/
├── main.dart                  # entry point (Firebase init aman, demo-friendly)
├── app.dart                   # MaterialApp + routing onboarding/home
├── core/
│   ├── config/app_config.dart # ⭐ SEMUA setting: demo mode, key, mood, filter
│   ├── theme/app_theme.dart   # ganti warna brand di sini (1 file)
│   └── widgets/rasa_widgets.dart  # kartu post, tombol peluk, dll
├── data/
│   ├── models/post_model.dart
│   ├── dummy_data.dart        # data demo (gampang diganti)
│   └── services/
│       ├── app_providers.dart # Riverpod: session, feed, replies, streak
│       └── gemini_service.dart# AI + fallback offline (anti-crash)
└── features/
    ├── onboarding/ feed/ post/ # feed + bikin post + detail
    ├── ai/ chat/ profile/ home/ # AI chat, biliar, profil, bottom-nav
```

## 🎨 Re-skin 10 Menit (Buat Buyer)

1. Nama & tagline → `lib/core/config/app_config.dart` (`appName`, `tagline`)
2. Warna brand → `lib/core/theme/app_theme.dart` (`seed`, `peach`)
3. Mood & pertanyaan harian → `kMoods`, `kDailyQuestions` di `app_config.dart`
4. Kata kasar → `kBannedWords` di `app_config.dart`
5. Package name → `flutter create . --project-name xxx --org com.kamu.xxx`

## 📄 Dokumen

- **`SETUP.md`** — setup Firebase, Gemini, keystore, Secrets GitHub, skema database, upgrade Biliar ke matchmaking real.
- **`JUAL.md`** — panduan jual source code (harga, marketplace, lisensi, script promosi).
- **`firestore.rules`** — security rules siap copy-paste ke Firebase Console.

## ⚠️ Catatan Penjual

- Konten anonim = wajib moderasi. Jangan skip `firestore.rules` + koleksi `reports`.
- AI bukan pengganti profesional. Ada pesan pengarah di system prompt (lihat `gemini_service.dart`).
