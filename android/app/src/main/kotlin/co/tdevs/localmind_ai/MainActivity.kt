package co.tdevs.localmind_ai

import android.app.ActivityManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, "localmind/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "info" -> result.success(deviceInfo())
                "isOnline" -> result.success(isOnline())
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "localmind/network").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                    val main = Handler(Looper.getMainLooper())
                    val callback = object : ConnectivityManager.NetworkCallback() {
                        override fun onAvailable(network: Network) {
                            main.post { events.success(isOnline()) }
                        }

                        override fun onLost(network: Network) {
                            main.post { events.success(isOnline()) }
                        }

                        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
                            main.post { events.success(isOnline()) }
                        }
                    }
                    cm.registerDefaultNetworkCallback(callback)
                    networkCallback = callback
                    events.success(isOnline())
                }

                override fun onCancel(arguments: Any?) {
                    unregisterNetworkCallback()
                }
            }
        )
    }

    override fun onDestroy() {
        unregisterNetworkCallback()
        super.onDestroy()
    }

    private fun unregisterNetworkCallback() {
        val callback = networkCallback ?: return
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        runCatching { cm.unregisterNetworkCallback(callback) }
        networkCallback = null
    }

    private fun isOnline(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val caps = cm.getNetworkCapabilities(cm.activeNetwork) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
            caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    private fun deviceInfo(): Map<String, Any?> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mem = ActivityManager.MemoryInfo()
        am.getMemoryInfo(mem)
        val stat = StatFs(filesDir.absolutePath)
        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "sdkInt" to Build.VERSION.SDK_INT,
            "socModel" to if (Build.VERSION.SDK_INT >= 31) Build.SOC_MODEL else null,
            "abis" to Build.SUPPORTED_ABIS.toList(),
            "cpuCores" to Runtime.getRuntime().availableProcessors(),
            "totalRamBytes" to mem.totalMem,
            "availRamBytes" to mem.availMem,
            "lowMemory" to mem.lowMemory,
            "isLowRamDevice" to am.isLowRamDevice,
            "memoryClassMb" to am.memoryClass,
            "largeMemoryClassMb" to am.largeMemoryClass,
            "freeStorageBytes" to stat.availableBytes,
            "totalStorageBytes" to stat.totalBytes,
            "isEmulator" to (Build.FINGERPRINT.contains("generic") || Build.HARDWARE.contains("ranchu")),
        )
    }
}
