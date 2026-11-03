package com.example.mynewapp.blocking

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import com.example.mynewapp.BlockedActivity

class InstagramAccessibilityService : AccessibilityService() {
  private var lastRedirect = 0L
  override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    if (event == null || event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED && event.eventType != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) return
    val expiry = getSharedPreferences("reboot_blocking", MODE_PRIVATE).getLong("expiresAt", 0L)
    if (expiry <= System.currentTimeMillis()) return
    val packageName = event.packageName?.toString() ?: ""
    val instagramApp = packageName == "com.instagram.android"
    val text = (event.text?.joinToString(" ") ?: "") + " " + (event.contentDescription?.toString() ?: "")
    val instagramWeb = packageName in setOf("com.android.chrome", "com.sec.android.app.sbrowser", "org.mozilla.firefox", "com.microsoft.emmx") &&
      Regex("(?i)(instagram\\.com|www\\.instagram)").containsMatchIn(text)
    if ((instagramApp || instagramWeb) && System.currentTimeMillis() - lastRedirect > 1800) {
      lastRedirect = System.currentTimeMillis()
      val intent = Intent(this, BlockedActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
      startActivity(intent)
    }
  }
  override fun onInterrupt() {}
}
