package com.example.mynewapp

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView

class BlockedActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) { super.onCreate(savedInstanceState)
    val root=LinearLayout(this).apply { orientation=LinearLayout.VERTICAL; gravity=Gravity.CENTER; setPadding(32,32,32,32); setBackgroundColor(Color.rgb(15,17,27)) }
    root.addView(TextView(this).apply { text="Take a breath."; textSize=30f; setTextColor(Color.WHITE); gravity=Gravity.CENTER })
    root.addView(TextView(this).apply { text="You made a commitment with Reboot. Instagram is paused until your session ends."; textSize=16f; setTextColor(Color.rgb(190,190,205)); gravity=Gravity.CENTER; setPadding(0,20,0,0) })
    setContentView(root)
  }
}
