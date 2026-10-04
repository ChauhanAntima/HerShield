package com.example.womensafety

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SmsManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.womensafety/sms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "sendDirectSms") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val phone = call.argument<String>("phone")?.trim()
                val message = call.argument<String>("msg")
                if (phone.isNullOrEmpty() || message.isNullOrEmpty()) {
                    result.error("INVALID_SMS", "A phone number and message are required.", null)
                    return@setMethodCallHandler
                }
                if (checkSelfPermission(Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
                    result.error("SMS_PERMISSION_DENIED", "SMS permission has not been granted.", null)
                    return@setMethodCallHandler
                }

                sendSmsAndWaitForRadio(phone, message, result)
            }
    }

    private fun sendSmsAndWaitForRadio(
        phone: String,
        message: String,
        result: MethodChannel.Result,
    ) {
        val requestCode = UUID.randomUUID().hashCode()
        val action = "$packageName.SMS_SENT.$requestCode"
        val handler = Handler(Looper.getMainLooper())
        val completed = AtomicBoolean(false)
        var receiver: BroadcastReceiver? = null

        fun unregisterReceiverSafely() {
            try {
                receiver?.let { unregisterReceiver(it) }
            } catch (_: IllegalArgumentException) {
                // It may already have been unregistered after a timeout.
            }
        }

        val timeout = Runnable {
            if (completed.compareAndSet(false, true)) {
                unregisterReceiverSafely()
                result.error(
                    "SMS_SEND_TIMEOUT",
                    "The phone did not confirm SMS transmission. Check the SIM and signal.",
                    null,
                )
            }
        }

        val sentReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (!completed.compareAndSet(false, true)) return
                handler.removeCallbacks(timeout)
                unregisterReceiverSafely()

                if (resultCode == Activity.RESULT_OK) {
                    // Android confirmed transmission to the mobile network; delivery is not guaranteed.
                    result.success("SMS_TRANSMITTED")
                } else {
                    val reason = when (resultCode) {
                        SmsManager.RESULT_ERROR_NO_SERVICE -> "No mobile network service is available."
                        SmsManager.RESULT_ERROR_RADIO_OFF -> "The phone radio is off."
                        SmsManager.RESULT_ERROR_LIMIT_EXCEEDED -> "The phone's SMS sending limit was reached."
                        SmsManager.RESULT_ERROR_NULL_PDU -> "The phone could not encode the SMS."
                        else -> "The phone could not transmit the SMS (code $resultCode)."
                    }
                    result.error("SMS_TRANSMISSION_FAILED", reason, resultCode)
                }
            }
        }
        receiver = sentReceiver

        try {
            val filter = IntentFilter(action)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(sentReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("DEPRECATION")
                registerReceiver(sentReceiver, filter)
            }

            val callbackIntent = Intent(action).setPackage(packageName)
            val sentCallback = PendingIntent.getBroadcast(
                this,
                requestCode,
                callbackIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }

            handler.postDelayed(timeout, 20_000L)
            smsManager.sendTextMessage(phone, null, message, sentCallback, null)
        } catch (error: Exception) {
            handler.removeCallbacks(timeout)
            if (completed.compareAndSet(false, true)) {
                unregisterReceiverSafely()
                result.error(
                    "SMS_SEND_FAILED",
                    error.localizedMessage ?: "The phone could not start the SMS.",
                    null,
                )
            }
        }
    }
}
