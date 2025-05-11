// File: android/app/build.gradle.kts

// Import Properties if not already auto-imported by your IDE
import java.util.Properties
import java.io.FileInputStream

// Create a new Properties object
val localProperties = Properties()
// Define the path to your local.properties file
val localPropertiesFile = rootProject.file("local.properties") // Assumes local.properties is in the android folder's parent (project root)

// Load the properties if the file exists
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}


plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // This line applies the plugin
}

// Define a local variable for the Flutter SDK path if needed, or rely on Flutter's environment
val flutterRootPath = localProperties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
if (flutterRootPath == null) {
    throw GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file or FLUTTER_ROOT environment variable.")
}

// Read Flutter version properties
val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"


android {
    namespace = "com.alpentor.wwjd" // Ensure this is your correct new package name
    compileSdk = 35 // Or use flutter.compileSdkVersion if defined by Flutter plugin
    ndkVersion = "27.0.12077973" // As per your file, ensure this is intended

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.alpentor.wwjd" // Ensure this is your correct new package name
        minSdk = 23 // Or use flutter.minSdkVersion
        targetSdk = 34 // Or use flutter.targetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // Use the latest BoM

    // Add the dependencies for Firebase products you want to use
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")

    // Other dependencies
    // implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version") // Usually managed
}

