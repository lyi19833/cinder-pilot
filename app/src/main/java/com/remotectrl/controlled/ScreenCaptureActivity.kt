package com.remotectrl.controlled

import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.remotectrl.R

class ScreenCaptureActivity : AppCompatActivity() {
    private val REQUEST_CODE = 1000

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_screen_capture)

        val startBtn = findViewById<Button>(R.id.startCaptureBtn)
        startBtn.setOnClickListener { requestScreenCapture() }
    }

    private fun requestScreenCapture() {
        val mpm = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        startActivityForResult(mpm.createScreenCaptureIntent(), REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE && resultCode == RESULT_OK && data != null) {
            val intent = Intent(this, ScreenCaptureService::class.java)
            intent.putExtra("resultCode", resultCode)
            intent.putExtra("data", data)
            startForegroundService(intent)
            Toast.makeText(this, "Screen capture started", Toast.LENGTH_SHORT).show()
        }
    }
}
