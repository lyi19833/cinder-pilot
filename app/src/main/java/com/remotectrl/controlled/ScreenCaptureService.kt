package com.remotectrl.controlled

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.remotectrl.network.WsClient
import org.json.JSONObject
import java.util.Base64

class ScreenCaptureService : Service() {
    private var mediaProjection: MediaProjection? = null
    private var encoder: ScreenEncoder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val resultCode = intent?.getIntExtra("resultCode", -1) ?: -1
        val data = intent?.getParcelableExtra<Intent>("data")

        if (resultCode != -1 && data != null) {
            startCapture(resultCode, data)
        }

        return START_STICKY
    }

    private fun startCapture(resultCode: Int, data: Intent) {
        val mpManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mediaProjection = mpManager.getMediaProjection(resultCode, data)

        encoder = ScreenEncoder(this, mediaProjection!!) { jpegBytes ->
            val b64 = Base64.getEncoder().encodeToString(jpegBytes)
            WsClient.instance?.send("screen_frame", JSONObject()
                .put("data", b64)
                .put("timestamp", System.currentTimeMillis()))
        }
        encoder!!.start()

        startForeground(NOTIFICATION_ID, createNotification())
        Log.d("ScreenCaptureService", "Capture started")
    }

    private fun createNotification(): Notification {
        val channelId = "screen_capture"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Screen Capture",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Screen Capture Active")
            .setContentText("Remote control is capturing your screen")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
    }

    override fun onDestroy() {
        encoder?.stop()
        mediaProjection?.stop()
        super.onDestroy()
        Log.d("ScreenCaptureService", "Service destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val NOTIFICATION_ID = 1
    }
}
