# Flutter wrapper — Flutter's own rules are applied automatically, these cover
# the third-party plugins used by this app so R8 shrinking keeps their entry points.

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# flutter_local_notifications (reflection for scheduled/boot receivers + GSON)
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
# Keep generic type info used by the notifications plugin's GSON serialization
-keep class * extends com.google.gson.reflect.TypeToken

# just_audio / ExoPlayer (Azaan playback)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# in_app_purchase / Play Billing
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.** { *; }

# home_widget + androidx.glance
-keep class es.antonborri.home_widget.** { *; }
-keep class androidx.glance.** { *; }

# Keep Parcelable/enum members referenced reflectively
-keepclassmembers enum * { *; }
