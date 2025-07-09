# Stripe SDK - Keep all Stripe classes
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.**

# React Native Stripe SDK (even though you're using Flutter)
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Flutter Stripe
-keep class com.flutter.stripe.** { *; }
-dontwarn com.flutter.stripe.**

# General Flutter/Dart
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**