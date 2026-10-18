package co.tdevs.localmind_ai

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * On-device speech for the app. Speech-to-text uses only Android's on-device
 * recognizer (API 31+) and never the network recognizer; text-to-speech uses
 * only voices that do not need a network connection. Audio is never stored.
 */
class VoiceBridge(private val activity: Activity, messenger: BinaryMessenger) {
    companion object {
        const val MIC_PERMISSION_REQUEST = 4203
    }

    private var events: EventChannel.EventSink? = null
    private var recognizer: SpeechRecognizer? = null
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private val pendingTts = mutableListOf<() -> Unit>()
    private var pendingMicResult: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, "localmind/voice").setMethodCallHandler(::onCall)
        EventChannel(messenger, "localmind/voice/events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                    events = sink
                }

                override fun onCancel(arguments: Any?) {
                    events = null
                }
            }
        )
    }

    private fun emit(type: String, extra: Map<String, Any?> = emptyMap()) {
        activity.runOnUiThread { events?.success(mapOf("type" to type) + extra) }
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sttAvailability" -> sttAvailability(call.argument<String>("lang") ?: "en-US", result)
            "hasMicPermission" -> result.success(hasMic())
            "requestMicPermission" -> requestMic(result)
            "startListening" -> result.success(startListening(call.argument<String>("lang") ?: "en-US"))
            "stopListening" -> {
                recognizer?.stopListening()
                result.success(true)
            }
            "cancelListening" -> {
                destroyRecognizer()
                result.success(true)
            }
            "downloadSpeechLanguage" -> result.success(downloadLanguage(call.argument<String>("lang") ?: ""))
            "ttsVoices" -> withTts { result.success(offlineVoices(call.argument<String>("lang") ?: "en-US").map { it.name }) }
            "speak" -> withTts {
                result.success(
                    speak(
                        call.argument<String>("text") ?: "",
                        call.argument<String>("lang") ?: "en-US",
                        call.argument<String>("id") ?: "utt",
                    )
                )
            }
            "stopSpeaking" -> {
                tts?.stop()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    // ---- Speech-to-text ----

    private fun hasMic() =
        activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED

    private fun requestMic(result: MethodChannel.Result) {
        if (hasMic()) return result.success(true)
        pendingMicResult?.success(false)
        pendingMicResult = result
        activity.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), MIC_PERMISSION_REQUEST)
    }

    fun onPermissionResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != MIC_PERMISSION_REQUEST) return
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingMicResult?.success(granted)
        pendingMicResult = null
    }

    private fun recognizerIntent(lang: String) =
        Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, lang)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
        }

    private fun sttAvailability(lang: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 31) {
            return result.success(mapOf("onDevice" to false, "reason" to "sdk"))
        }
        if (!SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)) {
            return result.success(mapOf("onDevice" to false, "reason" to "noRecognizer"))
        }
        if (Build.VERSION.SDK_INT < 33) {
            // Languages cannot be queried before API 33; report "unknown".
            return result.success(mapOf("onDevice" to true, "languageStatus" to "unknown"))
        }
        val probe = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
        var answered = false
        fun reply(map: Map<String, Any?>) {
            if (answered) return
            answered = true
            probe.destroy()
            result.success(map)
        }
        probe.checkRecognitionSupport(
            recognizerIntent(lang),
            activity.mainExecutor,
            object : RecognitionSupportCallback {
                override fun onSupportResult(support: RecognitionSupport) {
                    val tag = lang.lowercase()
                    fun has(list: List<String>) = list.any { it.lowercase() == tag || it.lowercase().substringBefore('-') == tag.substringBefore('-') }
                    val status = when {
                        has(support.installedOnDeviceLanguages) -> "installed"
                        has(support.pendingOnDeviceLanguages) -> "pending"
                        has(support.supportedOnDeviceLanguages) -> "downloadable"
                        else -> "unsupported"
                    }
                    reply(mapOf("onDevice" to true, "languageStatus" to status))
                }

                override fun onError(error: Int) {
                    reply(mapOf("onDevice" to true, "languageStatus" to "unknown", "error" to error))
                }
            }
        )
    }

    /** Asks the system to download an on-device speech pack. User-initiated only. */
    private fun downloadLanguage(lang: String): Boolean {
        if (Build.VERSION.SDK_INT < 33 || lang.isEmpty()) return false
        return runCatching {
            val r = SpeechRecognizer.createOnDeviceSpeechRecognizer(activity)
            r.triggerModelDownload(recognizerIntent(lang))
            r.destroy()
        }.isSuccess
    }

    private fun startListening(lang: String): Boolean {
        if (Build.VERSION.SDK_INT < 31 || !hasMic()) return false
        if (!SpeechRecognizer.isOnDeviceRecognitionAvailable(activity)) return false
        destroyRecognizer()
        val r = runCatching { SpeechRecognizer.createOnDeviceSpeechRecognizer(activity) }.getOrNull()
            ?: return false
        r.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) = emit("listening")
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) = emit("level", mapOf("db" to rmsdB.toDouble()))
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() = emit("speechEnded")
            override fun onError(error: Int) {
                emit("error", mapOf("code" to error))
                destroyRecognizer()
            }

            override fun onResults(results: Bundle?) {
                emit("final", mapOf("text" to firstResult(results)))
                destroyRecognizer()
            }

            override fun onPartialResults(partialResults: Bundle?) =
                emit("partial", mapOf("text" to firstResult(partialResults)))

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
        recognizer = r
        r.startListening(recognizerIntent(lang))
        return true
    }

    private fun firstResult(b: Bundle?): String =
        b?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull() ?: ""

    private fun destroyRecognizer() {
        recognizer?.cancel()
        recognizer?.destroy()
        recognizer = null
    }

    // ---- Text-to-speech ----

    private fun withTts(action: () -> Unit) {
        if (ttsReady) return action()
        pendingTts += action
        if (tts != null) return
        tts = TextToSpeech(activity) { status ->
            ttsReady = status == TextToSpeech.SUCCESS
            if (ttsReady) {
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(id: String) = emit("ttsStart", mapOf("id" to id))
                    override fun onDone(id: String) = emit("ttsDone", mapOf("id" to id))
                    @Deprecated("Deprecated in Java")
                    override fun onError(id: String) = emit("ttsError", mapOf("id" to id))
                })
            }
            val queued = pendingTts.toList()
            pendingTts.clear()
            queued.forEach { it() }
        }
    }

    private fun offlineVoices(lang: String): List<Voice> {
        if (!ttsReady) return emptyList()
        val wanted = Locale.forLanguageTag(lang)
        return (tts?.voices ?: emptySet()).filter { v ->
            v.locale.language == wanted.language &&
                !v.isNetworkConnectionRequired &&
                !v.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
        }.sortedWith(compareBy({ it.locale.country != wanted.country }, { -it.quality }))
    }

    private fun speak(text: String, lang: String, id: String): Boolean {
        val engine = tts ?: return false
        val voice = offlineVoices(lang).firstOrNull() ?: return false
        engine.voice = voice
        val max = TextToSpeech.getMaxSpeechInputLength() - 1
        val parts = splitForTts(text, max)
        parts.forEachIndexed { i, part ->
            val mode = if (i == 0) TextToSpeech.QUEUE_FLUSH else TextToSpeech.QUEUE_ADD
            val uid = if (i == parts.lastIndex) id else "$id#$i"
            engine.speak(part, mode, null, uid)
        }
        return parts.isNotEmpty()
    }

    private fun splitForTts(text: String, max: Int): List<String> {
        val out = mutableListOf<String>()
        var rest = text.trim()
        while (rest.length > max) {
            val cut = rest.lastIndexOfAny(charArrayOf('.', '!', '?', '।', '\n'), max).takeIf { it > 0 } ?: max
            out += rest.substring(0, cut + 1).trim()
            rest = rest.substring(cut + 1).trim()
        }
        if (rest.isNotEmpty()) out += rest
        return out
    }

    fun dispose() {
        destroyRecognizer()
        tts?.shutdown()
        tts = null
        ttsReady = false
    }
}
