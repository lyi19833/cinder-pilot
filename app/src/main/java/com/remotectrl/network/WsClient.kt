package com.remotectrl.network

import android.util.Log
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString
import org.json.JSONObject

class WsClient(private val handler: MessageHandler) : WebSocketListener() {
    private var ws: WebSocket? = null
    private val client = OkHttpClient()

    fun connect(url: String) {
        val request = Request.Builder().url(url).build()
        ws = client.newWebSocket(request, this)
    }

    fun send(type: String, payload: JSONObject) {
        val msg = JSONObject()
            .put("type", type)
            .put("payload", payload)
        ws?.send(msg.toString())
    }

    fun disconnect() {
        ws?.close(1000, "Normal closure")
    }

    override fun onOpen(webSocket: WebSocket, response: okhttp3.Response) {
        Log.d("WsClient", "Connected")
        handler.onConnected()
    }

    override fun onMessage(webSocket: WebSocket, text: String) {
        try {
            val msg = JSONObject(text)
            handler.onMessage(msg)
        } catch (e: Exception) {
            Log.e("WsClient", "Parse error: ${e.message}")
        }
    }

    override fun onFailure(webSocket: WebSocket, t: Throwable, response: okhttp3.Response?) {
        Log.e("WsClient", "Failure: ${t.message}")
        handler.onDisconnected()
    }

    override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
        Log.d("WsClient", "Closed: $code $reason")
        handler.onDisconnected()
    }

    companion object {
        var instance: WsClient? = null
    }
}
