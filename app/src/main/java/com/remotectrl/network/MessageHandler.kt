package com.remotectrl.network

import org.json.JSONObject

interface MessageHandler {
    fun onConnected()
    fun onDisconnected()
    fun onMessage(msg: JSONObject)
}
