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
    namespace = "com.prabhix.mailroom"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "com.prabhix.mailroom"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["appAuthRedirectScheme"] = "com.prabhix.mailroom"
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
