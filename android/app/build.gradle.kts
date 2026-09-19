plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abdorx.app.amra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // تفعيل الـ Desugaring ضروري جداً لمكتبة الإشعارات والوقت
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.abdorx.app.amra"
        // يفضل وضع رقم صريح هنا إذا واجهت مشاكل مع flutter.minSdkVersion
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = 40
        versionName = flutter.versionName
        
        multiDexEnabled = true
    }

    // إجبار أندرويد على تضمين مجلد الموارد (raw)
    sourceSets {
        getByName("main") {
            res.srcDirs("src/main/res")
        }
    }

    buildTypes {
        release {
            // نستخدم إعدادات الديباج للتوقيع مؤقتاً ليعمل الـ APK فوراً
            signingConfig = signingConfigs.getByName("debug")
            
            // --- أهم سطرين لحل مشكلة اختفاء صوت الآذان ---
            isMinifyEnabled = false
            isShrinkResources = false
            // ------------------------------------------
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // مكتبة دعم الميزات الحديثة على إصدارات أندرويد القديمة
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// حل مشكلة تعارض مكتبات الـ Glance والـ Compose مع إصدار الـ Gradle الحالي
configurations.all {
    resolutionStrategy {
        force("androidx.glance:glance:1.1.0")
        force("androidx.glance:glance-appwidget:1.1.0")
        force("androidx.compose.runtime:runtime:1.7.0")
    }
}