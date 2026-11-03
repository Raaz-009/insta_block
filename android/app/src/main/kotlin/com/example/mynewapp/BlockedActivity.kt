package com.example.mynewapp

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class BlockedActivity : Activity() {
  private val prefs by lazy { getSharedPreferences("reboot_blocking", MODE_PRIVATE) }
  override fun onCreate(savedInstanceState: Bundle?) { super.onCreate(savedInstanceState); render() }
  override fun onNewIntent(intent: android.content.Intent) { super.onNewIntent(intent); render() }
  private fun render() {
    val root=LinearLayout(this).apply { orientation=LinearLayout.VERTICAL;gravity=Gravity.CENTER;setPadding(32,32,32,32);setBackgroundColor(Color.rgb(15,17,27)) }
    root.addView(TextView(this).apply { text="Take a breath.";textSize=30f;setTextColor(Color.WHITE);gravity=Gravity.CENTER })
    root.addView(TextView(this).apply { text="You made a commitment with Reboot. Your selected app or Instagram website is paused until your session ends.";textSize=16f;setTextColor(Color.rgb(190,190,205));gravity=Gravity.CENTER;setPadding(0,20,0,24) })
    val expiry=prefs.getLong("expiresAt",0L);val remaining=((expiry-System.currentTimeMillis()).coerceAtLeast(0)/1000/60)
    root.addView(TextView(this).apply { text="About $remaining minutes remaining";textSize=13f;setTextColor(Color.rgb(170,175,195));gravity=Gravity.CENTER })
    val used=prefs.getBoolean("bypassUsed",false)
    if(!used && expiry>System.currentTimeMillis()) root.addView(Button(this).apply {
      text="Use my one-time 5-minute bypass"
      setOnClickListener { prefs.edit().putBoolean("bypassUsed",true).putLong("bypassUntil",System.currentTimeMillis()+5*60*1000L).apply();finish() }
    }) else if(used) root.addView(TextView(this).apply { text="Your one-time bypass has already been used.";textSize=12f;setTextColor(Color.rgb(190,190,205));gravity=Gravity.CENTER;setPadding(0,22,0,0) })
    root.addView(Button(this).apply { text="Return";setOnClickListener{finish()} })
    setContentView(root)
  }
}
