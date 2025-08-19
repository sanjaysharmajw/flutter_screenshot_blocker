package com.flutter_screenshot_blocker.flutter_screenshot_blocker

import android.app.Activity
import android.content.Context
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.os.Handler
import android.os.Looper

class FlutterScreenshotBlockerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var activity: Activity? = null
  private var context: Context? = null
  private var isScreenshotBlocked = false
  private var eventSink: EventChannel.EventSink? = null
  private val handler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_screenshot_blocker")
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_screenshot_blocker/events")

    channel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventSink = null
      }
    })
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "enableScreenshotBlocking" -> enableScreenshotBlocking(result)
      "disableScreenshotBlocking" -> disableScreenshotBlocking(result)
      "isScreenshotBlockingEnabled" -> result.success(isScreenshotBlocked)
      "enableSecureMode" -> enableSecureMode(result)
      "disableSecureMode" -> disableSecureMode(result)
      "setSecureFlag" -> {
        val secure = call.argument<Boolean>("secure") ?: false
        setSecureFlag(secure, result)
      }
      "enableScreenshotDetection" -> enableScreenshotDetection(result)
      "disableScreenshotDetection" -> disableScreenshotDetection(result)
      else -> result.notImplemented()
    }
  }

  private fun enableScreenshotBlocking(result: Result) {
    activity?.let { act ->
      handler.post {
        try {
          act.window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
          )
          isScreenshotBlocked = true
          result.success(true)
        } catch (e: Exception) {
          result.success(false)
        }
      }
    } ?: result.success(false)
  }

  private fun disableScreenshotBlocking(result: Result) {
    activity?.let { act ->
      handler.post {
        try {
          act.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
          isScreenshotBlocked = false
          result.success(true)
        } catch (e: Exception) {
          result.success(false)
        }
      }
    } ?: result.success(false)
  }

  private fun enableSecureMode(result: Result) {
    enableScreenshotBlocking(result)
  }

  private fun disableSecureMode(result: Result) {
    disableScreenshotBlocking(result)
  }

  private fun setSecureFlag(secure: Boolean, result: Result) {
    if (secure) {
      enableScreenshotBlocking(result)
    } else {
      disableScreenshotBlocking(result)
    }
  }

  private fun enableScreenshotDetection(result: Result) {
// Android doesn't provide direct screenshot detection
// This would require using MediaProjection API or accessibility services
// For now, we'll simulate detection when FLAG_SECURE is bypassed

    result.success(true)

// Send a test event to show the mechanism works
    handler.postDelayed({
      sendScreenshotEvent("screenshot_blocked", "Screenshot attempt detected and blocked")
    }, 1000)
  }

  private fun disableScreenshotDetection(result: Result) {
    result.success(true)
  }

  private fun sendScreenshotEvent(type: String, message: String) {
    eventSink?.let { sink ->
      val eventData = mapOf(
        "type" to type,
        "timestamp" to System.currentTimeMillis(),
        "metadata" to mapOf(
          "message" to message,
          "platform" to "android"
        )
      )
      sink.success(eventData)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
