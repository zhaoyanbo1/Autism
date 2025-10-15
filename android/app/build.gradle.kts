// --------------------  插件区  --------------------
plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter 插件
    id("dev.flutter.flutter-gradle-plugin")

    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
}

// --------------------  Android 构建配置  --------------------
android {
    namespace = "com.example.app_autism_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app_autism_demo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM：统一版本管理
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // 核心 Firebase SDK（你需要哪个加哪个）
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")
    // 若使用 Realtime Database，可替换为：
    // implementation("com.google.firebase:firebase-database")
}
