package com.remotectrl

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.remotectrl.auth.AuthManager
import com.remotectrl.auth.QrPairActivity
import com.remotectrl.controller.ControllerActivity
import com.remotectrl.controlled.QrGenerateActivity
import com.remotectrl.controlled.ScreenCaptureActivity
import com.remotectrl.network.MessageHandler
import com.remotectrl.network.WsClient
import com.remotectrl.storage.PairStorage
import org.json.JSONObject

class MainActivity : AppCompatActivity(), MessageHandler {
    private lateinit var wsClient: WsClient
    private lateinit var serverUrlInput: EditText
    private var currentMode: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        serverUrlInput = findViewById(R.id.serverUrl)
        val controllerBtn = findViewById<Button>(R.id.controllerBtn)
        val controlledBtn = findViewById<Button>(R.id.controlledBtn)
        val qrPairBtn = findViewById<Button>(R.id.qrPairBtn)

        wsClient = WsClient(this)
        WsClient.instance = wsClient

        serverUrlInput.setText("ws://192.168.1.100:8080")

        controllerBtn.setOnClickListener { connectAsController() }
        controlledBtn.setOnClickListener { connectAsControlled() }
        qrPairBtn.setOnClickListener { startActivity(Intent(this, QrGenerateActivity::class.java)) }
    }

    private fun connectAsController() {
        val url = serverUrlInput.text.toString()
        if (url.isEmpty()) {
            Toast.makeText(this, "请输入服务器地址", Toast.LENGTH_SHORT).show()
            return
        }

        currentMode = "controller"
        wsClient.connect(url)
    }

    private fun connectAsControlled() {
        val url = serverUrlInput.text.toString()
        if (url.isEmpty()) {
            Toast.makeText(this, "请输入服务器地址", Toast.LENGTH_SHORT).show()
            return
        }

        currentMode = "controlled"
        wsClient.connect(url)
    }

    override fun onConnected() {
        val deviceId = AuthManager.getOrCreateDeviceId(this)
        val token = AuthManager.getToken(this)

        wsClient.send("auth_request", JSONObject()
            .put("deviceId", deviceId)
            .put("token", token))
    }

    override fun onDisconnected() {
        Toast.makeText(this, "连接已断开", Toast.LENGTH_SHORT).show()
    }

    override fun onMessage(msg: JSONObject) {
        val type = msg.getString("type")
        val payload = msg.getJSONObject("payload")

        when (type) {
            "auth_response" -> {
                if (payload.getBoolean("success")) {
                    val token = payload.getString("token")
                    AuthManager.saveToken(this, token)
                    Toast.makeText(this, "认证成功", Toast.LENGTH_SHORT).show()

                    when (currentMode) {
                        "controller" -> startActivity(Intent(this, ControllerActivity::class.java))
                        "controlled" -> startActivity(Intent(this, ScreenCaptureActivity::class.java))
                    }
                } else {
                    Toast.makeText(this, "认证失败", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
}
