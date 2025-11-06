package com.github.darksider_05.livetext.live_text.live_text

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.github.darksider_05.livetext.live_text.live_text/ip"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLocalIPv4" -> result.success(NetworkUtils.getLocalIPv4())
                    else -> result.notImplemented()
                }
            }
    }
}