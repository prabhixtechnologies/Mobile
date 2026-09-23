# ML Kit creates these registrars with Class.getDeclaredConstructor().
# mobile_scanner only keeps com.google.mlkit.* (one package), so R8 removed
# the no-arg constructors and BarcodeScanning.getClient() crashed.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
