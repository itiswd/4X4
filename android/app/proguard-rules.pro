# Keep Supabase classes
-keep class io.supabase.** { *; }
-keepclassmembers class io.supabase.** { *; }

# Keep Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Keep serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# Keep network classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }