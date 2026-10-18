# Plugins that call their Kotlin/Java code from Dart over JNI (jnigen) look up
# classes and methods by name at runtime. R8 can't see those calls, so without
# these rules it strips or renames them and the release app hangs on the splash
# screen (e.g. NoSuchMethodError for SharedPreferencesApiRegistrar.getAll).
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
# The generated JNI bindings also reach Kotlin runtime/coroutine classes by name
# (Continuation, CoroutineSingletons, Unit, Result, ...).
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }

# Tesseract / Leptonica native code calls back into these classes and fields.
-keep class com.googlecode.tesseract.android.** { *; }
-keep class com.googlecode.leptonica.android.** { *; }
