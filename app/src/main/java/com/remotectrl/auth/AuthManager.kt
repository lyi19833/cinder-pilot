package com.remotectrl.auth

import android.content.Context
import java.util.UUID

object AuthManager {
    private const val PREFS = "auth"
    private const val KEY_TOKEN = "token"
    private const val KEY_DEVICE_ID = "deviceId"

    fun getOrCreateDeviceId(ctx: Context): String {
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return prefs.getString(KEY_DEVICE_ID, null) ?: UUID.randomUUID().toString().also {
            prefs.edit().putString(KEY_DEVICE_ID, it).apply()
        }
    }

    fun saveToken(ctx: Context, token: String) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_TOKEN, token)
            .apply()
    }

    fun getToken(ctx: Context): String? {
        return ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_TOKEN, null)
    }

    fun clearAuth(ctx: Context) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .clear()
            .apply()
    }
}
