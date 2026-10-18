package co.tdevs.localmind_ai

import android.os.Handler
import android.os.Looper
import com.googlecode.tesseract.android.TessBaseAPI
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Offline OCR with Tesseract (LSTM engine). Images arrive as 8-bit grayscale
 * pixels rendered from a PDF page; nothing is stored or sent anywhere.
 */
class OcrBridge(messenger: BinaryMessenger) {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var api: TessBaseAPI? = null
    private var loadedKey: String? = null

    init {
        MethodChannel(messenger, "localmind/ocr").setMethodCallHandler(::onCall)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "recognize" -> {
                val dataPath = call.argument<String>("dataPath")
                val langs = call.argument<String>("langs")
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                val pixels = call.argument<ByteArray>("pixels")
                if (dataPath == null || langs == null || width == null || height == null ||
                    pixels == null || pixels.size != width * height
                ) {
                    return result.error("bad_args", "Invalid OCR arguments", null)
                }
                worker.execute {
                    val out = runCatching { recognize(dataPath, langs, width, height, pixels) }
                    main.post {
                        out.fold(
                            onSuccess = { result.success(it) },
                            onFailure = { result.error("ocr_failed", it.message, null) },
                        )
                    }
                }
            }
            "release" -> worker.execute {
                release()
                main.post { result.success(true) }
            }
            else -> result.notImplemented()
        }
    }

    private fun recognize(
        dataPath: String,
        langs: String,
        width: Int,
        height: Int,
        pixels: ByteArray,
    ): Map<String, Any> {
        val key = "$dataPath|$langs"
        if (loadedKey != key) {
            release()
            val created = TessBaseAPI()
            if (!created.init(dataPath, langs, TessBaseAPI.OEM_LSTM_ONLY)) {
                created.recycle()
                throw IllegalStateException("Tesseract could not load language data")
            }
            created.setPageSegMode(TessBaseAPI.PageSegMode.PSM_AUTO)
            api = created
            loadedKey = key
        }
        val tess = api!!
        tess.setImage(pixels, width, height, 1, width)
        val text = tess.getUTF8Text() ?: ""
        val confidence = tess.meanConfidence()
        tess.clear()
        return mapOf("text" to text, "confidence" to confidence)
    }

    private fun release() {
        api?.recycle()
        api = null
        loadedKey = null
    }

    fun dispose() {
        worker.execute { release() }
        worker.shutdown()
    }
}
