package com.example.android_printer_service

import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.print.PrintAttributes
import android.print.PrintAttributes.Resolution
import android.print.PrinterCapabilitiesInfo
import android.print.PrinterId
import android.print.PrinterInfo
import android.printservice.PrintJob
import android.printservice.PrintService
import android.printservice.PrinterDiscoverySession
import android.util.Log
import java.io.*
import java.text.SimpleDateFormat
import java.util.*


class ForwardPrintService : PrintService() {

    private var printerInfo: PrinterInfo? = null

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "#onCreate()")
        printerInfo = PrinterInfo.Builder(generatePrinterId("AppName_Print_Service"),
                "AppName_Print_Service", PrinterInfo.STATUS_IDLE).build()
    }

    override fun onConnected() {
        Log.i(TAG, "#onConnected()")
        super.onConnected()
    }

    override fun onDisconnected() {
        super.onDisconnected()
        Log.i(TAG, "#onDisconnected()")
    }

    override fun onCreatePrinterDiscoverySession(): PrinterDiscoverySession? {
        return printerInfo?.let { ForwardPrinterDiscoverySession(it) }
    }

    override fun onRequestCancelPrintJob(printJob: PrintJob) {
        printJob.cancel()
    }

    override fun onPrintJobQueued(printJob: PrintJob?) {
        if (printJob != null) {
            try {
                val path = getFilePath(printJob)
                if (path != null) {
                    ForwardPrintPlugin.getInstance().pushFile(path)
                    val intent = packageManager.getLaunchIntentForPackage(packageName)
                    if (intent != null) {
                        Log.i(TAG, "#openApp()")
                        intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                    }
                }

            } catch (e: Exception) {
                Log.e(TAG, e.toString())
            } finally {
                printJob.complete()
            }
        }
    }

    private fun getFilePath(printJob: PrintJob): String? {
        if (printJob.isQueued) {
            printJob.start()
        }

        val format = SimpleDateFormat("yyyy_MM_dd", Locale.getDefault())
        val currentDate = Date()
        
        val fileName = "AppName_Print_Service_" + format.format(currentDate) + "_" + System.currentTimeMillis().toString() + ".pdf"

        val file = File(filesDir, fileName)
        val inS: InputStream?
        val outS: FileOutputStream?
        try {
            inS = FileInputStream(printJob.document.data!!.fileDescriptor)
            outS = FileOutputStream(file)
            val buffer = ByteArray(1024)
            var read: Int
            while (inS.read(buffer).also { read = it } != -1) {
                outS.write(buffer, 0, read)
            }
            inS.close()
            outS.flush()
            outS.close()
            return file.path
        } catch (ioe: IOException) {
            Log.e(TAG, ioe.toString())
        }
        return null
    }

    companion object {
        const val TAG = "ForwardPrintService"
    }
}

internal class ForwardPrinterDiscoverySession(printerInfo: PrinterInfo) : PrinterDiscoverySession() {
    private val printerInfo: PrinterInfo

    init {
        val capabilities = PrinterCapabilitiesInfo.Builder(printerInfo.id)
                .addMediaSize(PrintAttributes.MediaSize.ISO_A4, true)
                .addResolution(Resolution("1234", "Default", 200, 200), true)
                .setColorModes(PrintAttributes.COLOR_MODE_COLOR, PrintAttributes.COLOR_MODE_COLOR)
                .build()
        this.printerInfo = PrinterInfo.Builder(printerInfo)
                .setCapabilities(capabilities)
                .build()
    }

    override fun onStartPrinterDiscovery(priorityList: List<PrinterId>) {
        val printers: MutableList<PrinterInfo> = ArrayList()
        printers.add(printerInfo)
        addPrinters(printers)
    }

    override fun onStopPrinterDiscovery() {}
    override fun onValidatePrinters(printerIds: List<PrinterId>) {}
    override fun onStartPrinterStateTracking(printerId: PrinterId) {}
    override fun onStopPrinterStateTracking(printerId: PrinterId) {}
    override fun onDestroy() {}
}