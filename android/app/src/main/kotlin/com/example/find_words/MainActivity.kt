package com.example.find_words

import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter/tts"
    private var textToSpeech: TextToSpeech? = null
    private var isInitialized = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    initializeTTS(result)
                }
                "speak" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        speak(text, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is required", null)
                    }
                }
                "stop" -> {
                    stop(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeTTS(result: MethodChannel.Result) {
        textToSpeech = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                val langResult = textToSpeech?.setLanguage(Locale.US)
                if (langResult == TextToSpeech.LANG_MISSING_DATA || langResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                    result.error("TTS_ERROR", "Language not supported", null)
                } else {
                    isInitialized = true
                    result.success(true)
                }
            } else {
                result.error("TTS_ERROR", "Failed to initialize TTS", null)
            }
        }
    }

    private fun speak(text: String, result: MethodChannel.Result) {
        if (!isInitialized || textToSpeech == null) {
            result.error("TTS_NOT_INITIALIZED", "TTS not initialized", null)
            return
        }

        val utteranceId = UUID.randomUUID().toString()
        textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId)
        result.success(true)
    }

    private fun stop(result: MethodChannel.Result) {
        if (textToSpeech != null) {
            textToSpeech?.stop()
            result.success(true)
        } else {
            result.error("TTS_NOT_INITIALIZED", "TTS not initialized", null)
        }
    }

    override fun onDestroy() {
        textToSpeech?.shutdown()
        super.onDestroy()
    }
}
