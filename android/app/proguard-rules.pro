# Flutter wrapper — keep the Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# mobile_scanner uses CameraX which needs these kept
-keep class androidx.camera.** { *; }
-keep class com.google.mlkit.** { *; }

# Keep annotations used by CameraX
-keepattributes *Annotation*

# Play Core / Deferred components (referenced by Flutter engine)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Suppress warnings for missing optional dependencies
-dontwarn com.google.android.gms.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
