package com.example.mynewapp

import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.example.mynewapp.blocking.RebootAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
  private val channel = "com.reboot/blocking"
  private val prefs by lazy { getSharedPreferences("reboot_blocking", MODE_PRIVATE) }
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
      try {
        when (call.method) {
          "getInstalledApps" -> {
            val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
            val apps = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
              .filter { it.activityInfo.packageName != packageName }
              .distinctBy { it.activityInfo.packageName }
              .map { mapOf("name" to it.loadLabel(packageManager).toString(), "packageName" to it.activityInfo.packageName) }
              .sortedBy { (it["name"] as String).lowercase() }
            result.success(apps)
          }
          "startProtection" -> {
            val expiry = call.argument<Number>("expiresAt")?.toLong() ?: 0L
            val sessionId = call.argument<String>("sessionId") ?: "default"
            val previousSession = prefs.getString("sessionId", null)
            val packages = call.argument<List<String>>("packages") ?: emptyList()
            prefs.edit().putLong("expiresAt", expiry).putStringSet("selectedPackages", packages.toSet())
              .putString("sessionId", sessionId).apply()
            if (previousSession != sessionId) prefs.edit().putBoolean("bypassUsed", false).putLong("bypassUntil", 0L).apply()
            result.success(mapOf("accessibility" to isAccessibilityEnabled()))
          }
          "stopProtection" -> { prefs.edit().remove("expiresAt").remove("selectedPackages").remove("bypassUntil").apply(); result.success(true) }
          "openAccessibilitySettings" -> { startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)); result.success(true) }
          "getProtectionStatus" -> result.success(mapOf("accessibility" to isAccessibilityEnabled(), "active" to (prefs.getLong("expiresAt", 0L) > System.currentTimeMillis())))
          "storePassword" -> { val key=call.argument<String>("key")!!; val password=call.argument<String>("password")!!; encryptAndStore(key,password); result.success(true) }
          "revealPassword" -> { result.success(decrypt(call.argument<String>("key")!!)) }
          "deletePassword" -> { prefs.edit().remove("secret_${call.argument<String>("key")!!}").apply(); result.success(true) }
          else -> result.notImplemented()
        }
      } catch (e: Exception) { result.error("REBOOT_NATIVE_ERROR", e.message, null) }
    }
  }

  private fun isAccessibilityEnabled(): Boolean {
    val expected = "$packageName/${RebootAccessibilityService::class.java.name}"
    val enabled = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
    return enabled.split(':').any { it.equals(expected, true) }
  }

  private fun secretKey(alias: String): SecretKey {
    val ks=KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
    (ks.getKey(alias,null) as? SecretKey)?.let { return it }
    val generator=KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES,"AndroidKeyStore")
    generator.init(KeyGenParameterSpec.Builder(alias,KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
      .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).setRandomizedEncryptionRequired(true).build())
    return generator.generateKey()
  }
  private fun encryptAndStore(key:String, plain:String) {
    val alias="RebootPasswordKey"
    val cipher=Cipher.getInstance("AES/GCM/NoPadding"); cipher.init(Cipher.ENCRYPT_MODE,secretKey(alias))
    val encrypted=cipher.doFinal(plain.toByteArray(Charsets.UTF_8))
    val packed=Base64.encodeToString(cipher.iv,Base64.NO_WRAP)+":"+Base64.encodeToString(encrypted,Base64.NO_WRAP)
    prefs.edit().putString("secret_$key",packed).apply()
  }
  private fun decrypt(key:String):String? {
    val packed=prefs.getString("secret_$key",null) ?: return null
    val parts=packed.split(":",limit=2); val cipher=Cipher.getInstance("AES/GCM/NoPadding")
    cipher.init(Cipher.DECRYPT_MODE,secretKey("RebootPasswordKey"),GCMParameterSpec(128,Base64.decode(parts[0],Base64.NO_WRAP)))
    return String(cipher.doFinal(Base64.decode(parts[1],Base64.NO_WRAP)),Charsets.UTF_8)
  }
}
