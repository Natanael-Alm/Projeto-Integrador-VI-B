import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Senhas da chave de assinatura (arquivo fora do Git, ver docs/08-geracao-apk.md).
val arquivoDaChave = rootProject.file("key.properties")
val dadosDaChave = Properties()
if (arquivoDaChave.exists()) {
    dadosDaChave.load(FileInputStream(arquivoDaChave))
}

android {
    namespace = "br.com.vitrine.vitrine"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "br.com.vitrine"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = dadosDaChave.getProperty("keyAlias")
            keyPassword = dadosDaChave.getProperty("keyPassword")
            storeFile = dadosDaChave.getProperty("storeFile")?.let { file(it) }
            storePassword = dadosDaChave.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = if (arquivoDaChave.exists()) {
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
