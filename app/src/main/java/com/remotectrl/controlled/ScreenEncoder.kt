package com.remotectrl.controlled

import android.content.Context
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import com.remotectrl.network.WsClient
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.util.Base64

class ScreenEncoder(
    private val ctx: Context,
    private val mp: MediaProjection,
    private val onFrame: (ByteArray) -> Unit
) {
    private val metrics = DisplayMetrics()
    private var imageReader: ImageReader? = null
    private var virtualDisplay: android.media.projection.VirtualDisplay? = null

    fun start() {
        val wm = ctx.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        wm.defaultDisplay.getMetrics(metrics)

        val w = metrics.widthPixels / 2
        val h = metrics.heightPixels / 2

        imageReader = ImageReader.newInstance(w, h, PixelFormat.RGBA_8888, 2)
        virtualDisplay = mp.createVirtualDisplay(
            "capture", w, h, metrics.densityDpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader!!.surface, null, null
        )

        imageReader!!.setOnImageAvailableListener({ reader ->
            val image = reader.acquireLatestImage() ?: return@setOnImageAvailableListener
            val plane = image.planes[0]
            val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            bitmap.copyPixelsFromBuffer(plane.buffer)
            image.close()

            val baos = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 60, baos)
            onFrame(baos.toByteArray())
        }, Handler(Looper.getMainLooper()))

        Log.d("ScreenEncoder", "Started capturing at ${w}x${h}")
    }

    fun stop() {
        virtualDisplay?.release()
        imageReader?.close()
    }
}
