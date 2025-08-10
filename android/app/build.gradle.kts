plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services' // Firebase Google Services plugin
}

android {
    namespace = "com.example.vendor"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.vendor"
        minSdk = 21
        targetSdk = 34
        versionCode 1
        versionName "1.0"
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "1.8" // Recommended for Firebase and Kotlin interoperability
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.2.2')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.20"  // Ensure Kotlin stdlib
}

// Apply the Google services plugin after other plugins
apply plugin: 'com.google.gms.google-services'
