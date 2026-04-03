package com.remotectrl.controller

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.util.Log
import android.view.SurfaceView
import java.util.Base64

class ScreenRenderer(private val surface: SurfaceView) {
    fun renderFrame(base64Data: String) {
        try {
            val bytes = Base64.getDecoder().decode(base64Data)
            val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return
            val canvas = surface.holder.lockCanvas() ?: return

            canvas.drawBitmap(
                bitmap,
                null,
                Rect(0, 0, surface.width, surface.height),
                null
            )
            surface.holder.unlockCanvasAndPost(canvas)
        } catch (e: Exception) {
            Log.e("ScreenRenderer", "Render error: ${e.message}")
        }
    }
}
