package com.remotectrl.auth

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.remotectrl.R
import com.remotectrl.auth.AuthManager
import com.remotectrl.network.MessageHandler
import com.remotectrl.network.WsClient
import com.remotectrl.storage.PairStorage
import org.json.JSONObject

class QrPairActivity : AppCompatActivity(), MessageHandler {
    private lateinit var peerIdInput: EditText
    private lateinit var pairBtn: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_qr_pair)

        peerIdInput = findViewById(R.id.peerIdInput)
        pairBtn = findViewById(R.id.pairBtn)

        pairBtn.setOnClickListener { performPair() }

        WsClient.instance?.let { ws ->
            ws.handler = this
        }
    }

    private fun performPair() {
        val peerId = peerIdInput.text.toString()
        if (peerId.isEmpty()) {
            Toast.makeText(this, "Enter peer device ID", Toast.LENGTH_SHORT).show()
            return
        }

        // In real implementation, this would be from QR scan
        // For now, just send pair_confirm with temp token
        WsClient.instance?.send("pair_confirm", JSONObject()
            .put("peerDeviceId", peerId)
            .put("tempToken", "temp-token-from-qr"))
    }

    override fun onConnected() {}

    override fun onDisconnected() {}

    override fun onMessage(msg: JSONObject) {
        val type = msg.getString("type")
        val payload = msg.getJSONObject("payload")

        when (type) {
            "pair_confirm" -> {
                if (payload.getBoolean("success")) {
                    val peerDeviceId = payload.getString("peerDeviceId")
                    PairStorage.savePair(this, peerDeviceId)
                    Toast.makeText(this, "Paired successfully", Toast.LENGTH_SHORT).show()
                    finish()
                }
            }
        }
    }
}
