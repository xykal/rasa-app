#!/usr/bin/env bash
# RASA — Patch proyek Android hasil `flutter create` untuk build RELEASE:
# signing resmi (baca android/key.properties) + R8 (minify + shrinkResources).
# Mendukung Gradle Kotlin DSL (build.gradle.kts) maupun Groovy (build.gradle).
# Aman dijalankan ulang (ada guard anti double-patch).
set -euo pipefail

APP_DIR="android/app"
KTS="$APP_DIR/build.gradle.kts"
GROOVY="$APP_DIR/build.gradle"
MARKER="RASA release patch"

echo "=== RASA android release patch ==="

if [ ! -d "$APP_DIR" ]; then
  echo "ERROR: folder $APP_DIR tidak ada. Jalankan 'flutter create .' dulu."
  exit 1
fi

# 1. ProGuard rules (konservatif: Firebase / OneSignal / Flutter / Gson aman)
cat > "$APP_DIR/proguard-rules.pro" <<'EOF'
# RASA ProGuard/R8 rules — konservatif biar tidak ada crash di build release.
-keepattributes *Annotation*,InnerClasses,EnclosingMethod,Signature
# Flutter engine & embedding
-keep class io.flutter.** { *; }
# Firebase + Play services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
# OneSignal
-keep class com.onesignal.** { *; }
# Gson & JSON reflection
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }
# Play Core: direferensikan Flutter embedding (deferred components)
# tapi tidak dipakai app ini — aman diabaikan (fix umum R8 + Flutter).
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
EOF
echo "proguard-rules.pro ditulis"

# 2. Patch build script (deteksi DSL)
if [ -f "$KTS" ]; then
  echo "terdeteksi Kotlin DSL (build.gradle.kts)"
  if grep -q "$MARKER" "$KTS"; then
    echo "sudah di-patch, lewati"
    exit 0
  fi
  # 2a. Sisipkan import setelah blok plugins (pola resmi docs Flutter).
  #     WAJIB via import: accessor `java` di Kotlin DSL menimpa paket java.*,
  #     jadi `java.util.Properties` fully-qualified TIDAK bisa dipakai.
  python3 - "$KTS" <<'PYEOF'
import sys
path = sys.argv[1]
t = open(path).read()
if 'java.util.Properties' not in t:
    lines = t.split('\n')
    idx = next(i for i, l in enumerate(lines) if l.strip() == '}')
    lines.insert(idx + 1, 'import java.util.Properties\nimport java.io.FileInputStream')
    open(path, 'w').write('\n'.join(lines))
    print('import disisipkan')
else:
    print('import sudah ada, lewati')
PYEOF
  # 2b. Append signing + R8 (pola resmi docs Flutter).
  cat >> "$KTS" <<'EOF'

// ==== RASA release patch: signing resmi + R8 ====
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
EOF
  echo "build.gradle.kts di-patch"
elif [ -f "$GROOVY" ]; then
  echo "terdeteksi Groovy DSL (build.gradle)"
  if grep -q "$MARKER" "$GROOVY"; then
    echo "sudah di-patch, lewati"
    exit 0
  fi
  cat >> "$GROOVY" <<'EOF'

// ==== RASA release patch: signing resmi + R8 ====
def rasaKeyProps = new Properties()
def rasaKeyFile = rootProject.file('key.properties')
if (rasaKeyFile.exists()) { rasaKeyFile.withInputStream { rasaKeyProps.load(it) } }
android {
    signingConfigs {
        release {
            storeFile file(rasaKeyProps.getProperty('storeFile', 'upload-keystore.jks'))
            storePassword rasaKeyProps.getProperty('storePassword', '')
            keyAlias rasaKeyProps.getProperty('keyAlias', '')
            keyPassword rasaKeyProps.getProperty('keyPassword', '')
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
EOF
  echo "build.gradle di-patch"
else
  echo "ERROR: tidak ketemu $KTS maupun $GROOVY"
  exit 1
fi

echo "PATCH OK"
