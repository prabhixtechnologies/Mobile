import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val playKeystoreProperties = Properties()
val playKeystorePropertiesFile = listOf(
    rootProject.file("key.properties"),
    file("D:/Projects/KEYS/prabhix-play-upload.key.properties"),
).firstOrNull { it.exists() }
if (playKeystorePropertiesFile != null) {
    playKeystoreProperties.load(FileInputStream(playKeystorePropertiesFile))
}

android {
    namespace = "app.prabhix.fixflow"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    // Bytecode language level for the APK (Android ART).
    // Your machine can run Gradle on JDK 25 — that is separate from this target.
    // Java 21 is the newest LTS AGP 9 / Android tooling reliably supports.
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "app.prabhix.fixflow"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["appAuthRedirectScheme"] = "mobistack"
        manifestPlaceholders["usesCleartextTraffic"] = "true"
    }

    if (playKeystorePropertiesFile != null) {
        signingConfigs {
            create("release") {
                keyAlias = playKeystoreProperties.getProperty("keyAlias")
                keyPassword = playKeystoreProperties.getProperty("keyPassword")
                storeFile = file(playKeystoreProperties.getProperty("storeFile")!!)
                storePassword = playKeystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (playKeystorePropertiesFile != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
