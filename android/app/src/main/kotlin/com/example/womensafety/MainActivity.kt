//package com.example.womensafety
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()


package com.example.womensafety

import android.telephony.SmsManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.womensafety/sms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendDirectSms") {
                val num = call.argument<String>("phone")
                val msg = call.argument<String>("msg")

                try {
                    // 🔥 Fixed line: Yahan humne direct 31 (Android 12) use kiya hai
                    val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= 31) {
                        this.getSystemService(SmsManager::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        SmsManager.getDefault()
                    }

                    smsManager.sendTextMessage(num, null, msg, null, null)
                    result.success("SMS Sent Successfully")
                } catch (e: Exception) {
                    result.error("SMS_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}