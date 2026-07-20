# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Razorpay
-keep class com.razorpay.** { *; }
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-optimizations !method/removal/parameter
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
