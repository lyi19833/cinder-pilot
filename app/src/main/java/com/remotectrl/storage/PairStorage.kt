package com.remotectrl.storage

import android.content.Context

object PairStorage {
    private const val PREFS = "pair"
    private const val KEY_PEER_ID = "peerId"

    fun savePair(ctx: Context, peerDeviceId: String) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_PEER_ID, peerDeviceId)
            .apply()
    }

    fun getPairedDevice(ctx: Context): String? {
        return ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_PEER_ID, null)
    }

    fun clearPair(ctx: Context) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove(KEY_PEER_ID)
            .apply()
    }
}
