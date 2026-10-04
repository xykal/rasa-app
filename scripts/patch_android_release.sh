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
EOF
echo "proguard-rules.pro ditulis"

# 2. Append signing + R8 ke build script (deteksi DSL)
if [ -f "$KTS" ]; then
  echo "terdeteksi Kotlin DSL (build.gradle.kts)"
  if grep -q "$MARKER" "$KTS"; then
    echo "sudah di-patch, lewati"
    exit 0
  fi
  cat >> "$KTS" <<'EOF'

// ==== RASA release patch: signing resmi + R8 ====
val rasaKeyProps = java.util.Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
android {
    signingConfigs {
        create("release") {
            storeFile = file(rasaKeyProps.getProperty("storeFile", "upload-keystore.jks"))
            storePassword = rasaKeyProps.getProperty("storePassword", "")
            keyAlias = rasaKeyProps.getProperty("keyAlias", "")
            keyPassword = rasaKeyProps.getProperty("keyPassword", "")
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
