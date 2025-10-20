package com.example.flux_crash_handler

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.*

/** FluxCrashHandlerPlugin */
class FluxCrashHandlerPlugin :
    FlutterPlugin,
    MethodCallHandler {
    
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var defaultExceptionHandler: Thread.UncaughtExceptionHandler? = null
    
    companion object {
        private const val CRASH_FILE_NAME = "flux_crash_report.json"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flux_crash_handler")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "initialize" -> {
                initializeCrashHandler()
                result.success(null)
            }
            "getLastCrash" -> {
                val crashReport = getLastCrashReport()
                result.success(crashReport)
            }
            "triggerTestCrash" -> {
                result.success(null)
                // Trigger crash after returning result
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    throw RuntimeException("Test crash triggered by FluxCrashHandler")
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initializeCrashHandler() {
        defaultExceptionHandler = Thread.getDefaultUncaughtExceptionHandler()
        
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            saveCrashReport(throwable)
            defaultExceptionHandler?.uncaughtException(thread, throwable)
        }
    }

    private fun saveCrashReport(throwable: Throwable) {
        try {
            val context = applicationContext ?: return
            
            val timestamp = SimpleDateFormat(
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 
                Locale.US
            ).apply {
                timeZone = TimeZone.getTimeZone("UTC")
            }.format(Date())
            
            val stackTraceWriter = StringWriter()
            throwable.printStackTrace(PrintWriter(stackTraceWriter))
            val stackTrace = stackTraceWriter.toString()
            
            val errorMessage = throwable.message ?: throwable.toString()
            
            val crashData = JSONObject()
            crashData.put("error", errorMessage)
            crashData.put("timestamp", timestamp)
            crashData.put("stackTrace", stackTrace)
            
            val file = File(context.filesDir, CRASH_FILE_NAME)
            file.writeText(crashData.toString())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getLastCrashReport(): Map<String, String>? {
        try {
            val context = applicationContext ?: return null
            val file = File(context.filesDir, CRASH_FILE_NAME)
            
            if (!file.exists()) {
                return null
            }
            
            val content = file.readText()
            file.delete()
            
            val json = JSONObject(content)
            return mapOf(
                "error" to json.getString("error"),
                "timestamp" to json.getString("timestamp"),
                "stackTrace" to json.getString("stackTrace")
            )
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        applicationContext = null
    }
}
