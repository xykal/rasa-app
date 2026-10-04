#!/usr/bin/env bash
# RASA — Pasang branding ke proyek hasil `flutter create`:
# adaptive icon, legacy icon, splash bawaan, label app, ikon web.
set -euo pipefail

echo "=== RASA branding ==="

if [ ! -d "android/app/src/main" ]; then
  echo "ERROR: folder android belum ada. Jalankan 'flutter create .' dulu."
  exit 1
fi

# 1. resource Android (ikon + splash + warna)
cp -rf branding/android/res/. android/app/src/main/res/
# 1b. buang sisa template yg tidak dipakai lagi (referensi gradasi lama)
rm -f android/app/src/main/res/drawable/ic_launcher_background.xml \
      android/app/src/main/res/drawable-night/ic_launcher_background.xml
echo "android res dipasang"

# 2. label aplikasi
sed -i 's/android:label="rasa"/android:label="RASA"/' android/app/src/main/AndroidManifest.xml
grep -q 'android:label="RASA"' android/app/src/main/AndroidManifest.xml && echo "label OK"

# 3. ikon web (kalau folder web ada)
if [ -d "web/icons" ]; then
  cp -f branding/web/icons/*.png web/icons/
  cp -f branding/web/favicon.png web/favicon.png
  echo "web icons dipasang"
fi

echo "BRANDING OK"
