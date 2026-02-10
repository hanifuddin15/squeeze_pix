# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Services (used by IAP/Ads)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Android Billing Client (IAP)
-keep class com.android.billingclient.** { *; }

# Android WebView (Critical for Unity Ads)
-keep class android.webkit.** { *; }
-keep interface android.webkit.** { *; }
-dontwarn android.webkit.**

# Unity Ads (Broad)
-keep class com.unity3d.** { *; }
-dontwarn com.unity3d.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Default rules
-dontwarn javax.annotation.**
-keepattributes Signature
-keepattributes *Annotation*

# Google Play Core (Fix for missing classes in R8)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
