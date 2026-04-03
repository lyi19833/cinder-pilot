package com.remotectrl.controlled

import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.google.zxing.BarcodeFormat
import com.google.zxing.qrcode.QRCodeWriter
import com.remotectrl.R
import com.remotectrl.auth.AuthManager
import com.remotectrl.network.MessageHandler
import com.remotectrl.network.WsClient
import org.json.JSONObject

class QrGenerateActivity : AppCompatActivity(), MessageHandler {
    private lateinit var qrImageView: ImageView
    private lateinit var deviceIdText: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_qr_generate)

        qrImageView = findViewById(R.id.qrImageView)
        deviceIdText = findViewById(R.id.deviceIdText)

        val deviceId = AuthManager.getOrCreateDeviceId(this)
        deviceIdText.text = "Device ID: $deviceId"

        // 生成二维码
        generateQrCode(deviceId)

        WsClient.instance?.let { ws ->
            ws.handler = this
        }
    }

    private fun generateQrCode(deviceId: String) {
        try {
            val writer = QRCodeWriter()
            val qrData = JSONObject()
                .put("deviceId", deviceId)
                .put("tempToken", "temp-${System.currentTimeMillis()}")
                .toString()

            val bitMatrix = writer.encode(qrData, BarcodeFormat.QR_CODE, 512, 512)
            val width = bitMatrix.width
            val height = bitMatrix.height
            val bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.RGB_565)

            for (x in 0 until width) {
                for (y in 0 until height) {
                    bitmap.setPixel(x, y, if (bitMatrix[x, y]) android.graphics.Color.BLACK else android.graphics.Color.WHITE)
                }
            }

            qrImageView.setImageBitmap(bitmap)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onConnected() {}
    override fun onDisconnected() {}
    override fun onMessage(msg: JSONObject) {}
}
