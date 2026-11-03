package com.example.mynewapp

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.provider.Settings
import com.example.mynewapp.blocking.InstagramAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channel = "com.reboot/blocking"
  private var pendingResult: MethodChannel.Result? = null
  private val vpnRequestCode = 7812

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
      when (call.method) {
        "startProtection" -> {
          val expiry = call.argument<Long>("expiresAt") ?: 0L
          getSharedPreferences("reboot_blocking", MODE_PRIVATE).edit().putLong("expiresAt", expiry).apply()
          if (VpnService.prepare(this) != null) {
            pendingResult = result
            startActivityForResult(VpnService.prepare(this), vpnRequestCode)
          } else {
            startVpn(); result.success(mapOf("vpn" to true, "accessibility" to isAccessibilityEnabled()))
          }
        }
        "stopProtection" -> { stopService(Intent(this, InstagramVpnService::class.java)); getSharedPreferences("reboot_blocking", MODE_PRIVATE).edit().remove("expiresAt").apply(); result.success(true) }
        "openAccessibilitySettings" -> { startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)); result.success(true) }
        "getProtectionStatus" -> result.success(mapOf("vpn" to InstagramVpnService.running, "accessibility" to isAccessibilityEnabled()))
        else -> result.notImplemented()
      }
    }
  }

  private fun startVpn() { startForegroundService(Intent(this, InstagramVpnService::class.java).setAction(InstagramVpnService.ACTION_START)) }
  private fun isAccessibilityEnabled(): Boolean {
    val expected = "$packageName/${InstagramAccessibilityService::class.java.name}"
    val enabled = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
    return enabled.split(':').any { it.equals(expected, true) }
  }
  @Deprecated("Deprecated in Android API; used for VPN consent compatibility")
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    if (requestCode == vpnRequestCode) {
      if (resultCode == Activity.RESULT_OK) { startVpn(); pendingResult?.success(mapOf("vpn" to true, "accessibility" to isAccessibilityEnabled())) }
      else pendingResult?.error("VPN_PERMISSION_DENIED", "VPN permission was not granted", null)
      pendingResult = null
    }
  }
}
