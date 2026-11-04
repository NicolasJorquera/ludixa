import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Clave de carga para Play. key.properties y el .jks nunca se suben al repositorio;
// ver README > Firma de versiones.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// ID de aplicación de AdMob. Dev usa el de prueba público de Google; prod lo
// lee de admob.properties (appId=ca-app-pub-...~...), que nunca se sube.
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val admobPropertiesFile = rootProject.file("admob.properties")
val admobProperties = Properties()
if (admobPropertiesFile.exists()) {
    admobProperties.load(FileInputStream(admobPropertiesFile))
}

android {
    namespace = "io.github.nicolasjorquera.ludixa"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Fijado por Play Console al crear la app; no se puede cambiar. El
        // namespace (paquete del código Kotlin) sigue siendo el original.
        applicationId = "com.gonisoma.ludixa"
        // Android 7.0. Se revisa al integrar AdMob (H6) por si el SDK exige más.
        minSdk = 24
        // Exigido por Google Play desde el 31-ago-2026.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("upload") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Ludixa Dev")
            manifestPlaceholders["admobAppId"] = admobTestAppId
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Ludixa")
            manifestPlaceholders["admobAppId"] = admobProperties.getProperty("appId") ?: run {
                logger.warn("admob.properties no encontrado: prod usa el ID de prueba de AdMob y no genera ingresos.")
                admobTestAppId
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("upload")
            } else {
                // Solo para probar en local: Play rechaza paquetes firmados con la clave de depuración.
                logger.warn("key.properties no encontrado: la versión release se firma con la clave de depuración.")
                signingConfigs.getByName("debug")
            }
            // Tabla de símbolos de las librerías nativas dentro del App Bundle:
            // Play la usa para leer los fallos nativos en Android vitals (H8-01).
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }
}

flutter {
    source = "../.."
}
