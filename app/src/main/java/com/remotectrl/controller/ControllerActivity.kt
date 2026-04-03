package com.remotectrl.controller

import android.os.Bundle
import android.util.Log
import android.view.MotionEvent
import android.view.SurfaceView
import androidx.appcompat.app.AppCompatActivity
import com.remotectrl.R
import com.remotectrl.network.MessageHandler
import com.remotectrl.network.WsClient
import org.json.JSONObject

class ControllerActivity : AppCompatActivity(), MessageHandler {
    private lateinit var screenView: SurfaceView
    private lateinit var renderer: ScreenRenderer
    private var screenWidth = 0
    private var screenHeight = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_controller)

        screenView = findViewById(R.id.screenView)
        renderer = ScreenRenderer(screenView)

        screenView.setOnTouchListener { _, event ->
            handleTouch(event)
            true
        }

        WsClient.instance?.let { ws ->
            ws.handler = this
        }
    }

    private fun handleTouch(event: MotionEvent) {
        val x = event.x
        val y = event.y

        val action = when (event.action) {
            MotionEvent.ACTION_DOWN -> "tap"
            MotionEvent.ACTION_MOVE -> "move"
            MotionEvent.ACTION_UP -> "up"
            else -> return
        }

        // Normalize coordinates to 0.0-1.0
        val normX = x / screenView.width
        val normY = y / screenView.height

        WsClient.instance?.send("touch_event", JSONObject()
            .put("action", action)
            .put("x", normX)
            .put("y", normY))
    }

    override fun onConnected() {
        Log.d("ControllerActivity", "Connected")
    }

    override fun onDisconnected() {
        Log.d("ControllerActivity", "Disconnected")
    }

    override fun onMessage(msg: JSONObject) {
        val type = msg.getString("type")
        val payload = msg.getJSONObject("payload")

        when (type) {
            "screen_frame" -> {
                val data = payload.getString("data")
                renderer.renderFrame(data)
            }
            "peer_disconnected" -> {
                Log.d("ControllerActivity", "Peer disconnected")
            }
        }
    }
}
