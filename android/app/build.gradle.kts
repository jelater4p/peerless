import java.util.Properties

plugins {
    id("com.android.application")
    // Flutter Gradle eklentisi Android ve Kotlin eklentilerinden sonra uygulanmalı.
    id("dev.flutter.flutter-gradle-plugin")
}

// İmza anahtarı bilgileri android/key.properties dosyasından okunur.
// Bu dosya ve .jks anahtarı ASLA git'e eklenmez (bkz. docs/13-apk-dagitim.md).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.peerless.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Play Store'a çıktıktan sonra değiştirilemez.
        applicationId = "com.peerless.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Sürüm numaraları pubspec.yaml içindeki `version:` satırından gelir.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // key.properties varsa gerçek anahtarla, yoksa (deneme amaçlı) debug anahtarıyla imzalanır.
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
