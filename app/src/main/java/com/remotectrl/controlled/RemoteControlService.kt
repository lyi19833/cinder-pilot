package com.remotectrl.controlled

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class RemoteControlService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}

    override fun onInterrupt() {}

    fun injectTouch(action: String, x: Float, y: Float, x2: Float = 0f, y2: Float = 0f) {
        when (action) {
            "tap" -> performTap(x, y)
            "swipe" -> performSwipe(x, y, x2, y2)
        }
    }

    private fun performTap(x: Float, y: Float) {
        val path = Path().apply { moveTo(x, y) }
        val stroke = GestureDescription.StrokeDescription(path, 0, 100)
        dispatchGesture(GestureDescription.Builder().addStroke(stroke).build(), null, null)
        Log.d("RemoteControlService", "Tap at $x, $y")
    }

    private fun performSwipe(x1: Float, y1: Float, x2: Float, y2: Float) {
        val path = Path().apply { moveTo(x1, y1); lineTo(x2, y2) }
        val stroke = GestureDescription.StrokeDescription(path, 0, 300)
        dispatchGesture(GestureDescription.Builder().addStroke(stroke).build(), null, null)
        Log.d("RemoteControlService", "Swipe from $x1,$y1 to $x2,$y2")
    }

    override fun onServiceConnected() {
        instance = this
        Log.d("RemoteControlService", "Service connected")
    }

    companion object {
        var instance: RemoteControlService? = null
    }
}
