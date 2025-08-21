package com.example.android_printer_service

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

private const val MESSAGES_CHANNEL = "forward_print/messages"
private const val EVENTS_CHANNEL_DOCUMENT = "forward_print/events-document"

class ForwardPrintPlugin() : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private var mChannel: MethodChannel? = null
    private var eChannelDocument: EventChannel? = null

    private var initialDocument: JSONObject? = null
    private var latestDocument: JSONObject? = null
    private var eventSinkDocument: EventChannel.EventSink? = null

    fun pushFile(path: String) {
        val value = JSONObject().put("path", path)
        Log.i(TAG, "#sinkDataIntoStream $value")

        latestDocument = value
        eventSinkDocument?.success(value.toString())
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        instance = this
        val binaryMessenger = binding.binaryMessenger

        mChannel = MethodChannel(binaryMessenger, MESSAGES_CHANNEL)
        mChannel?.setMethodCallHandler(this)

        eChannelDocument = EventChannel(binaryMessenger, EVENTS_CHANNEL_DOCUMENT)
        eChannelDocument?.setStreamHandler(this)

        initialDocument = latestDocument
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel?.setMethodCallHandler(null)
        mChannel = null

        eChannelDocument?.setStreamHandler(null)
        eChannelDocument = null

        initialDocument = null
        latestDocument = null

        instance = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInitialDocument" -> result.success(initialDocument?.toString())
            "reset" -> {
                initialDocument = null
                latestDocument = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSinkDocument = events
    }

    override fun onCancel(arguments: Any?) {
        eventSinkDocument = null
    }

    companion object {
        const val TAG = "ForwardPrintPlugin"

        @Volatile
        private var instance: ForwardPrintPlugin? = null

        fun getInstance(): ForwardPrintPlugin {
            return instance ?: throw IllegalStateException("ForwardPrintPlugin not attached")
        }
    }
}