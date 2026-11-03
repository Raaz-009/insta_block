package com.example.mynewapp.blocking

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import com.example.mynewapp.BlockedActivity

class RebootAccessibilityService : AccessibilityService() {
  private val handler=Handler(Looper.getMainLooper())
  private var lastRedirect=0L
  private val prefs get()=getSharedPreferences("reboot_blocking", MODE_PRIVATE)
  override fun onServiceConnected() { super.onServiceConnected(); scheduleBoundaryCheck() }
  override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    if(event==null)return
    if(event.eventType !in setOf(AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED,AccessibilityEvent.TYPE_WINDOWS_CHANGED))return
    scheduleBoundaryCheck()
    val pkg=event.packageName?.toString() ?: return
    evaluate(pkg, collectVisibleText(event))
  }
  private fun collectVisibleText(event:AccessibilityEvent):String {
    val values=mutableListOf<String>(); event.text?.forEach{values.add(it.toString())}; event.contentDescription?.let{values.add(it.toString())}
    try { val root=rootInActiveWindow; if(root!=null){ fun walk(node:android.view.accessibility.AccessibilityNodeInfo?,depth:Int){if(node==null||depth>12)return;node.text?.let{values.add(it.toString())};node.contentDescription?.let{values.add(it.toString())};for(i in 0 until node.childCount)walk(node.getChild(i),depth+1)};walk(root,0);root.recycle() } } catch (_:Exception){}
    return values.joinToString(" ")
  }
  private fun evaluate(pkg:String,text:String) {
    val now=System.currentTimeMillis(); val expiry=prefs.getLong("expiresAt",0L)
    if(expiry<=now)return
    if(prefs.getLong("bypassUntil",0L)>now)return
    val selected=prefs.getStringSet("selectedPackages",emptySet()) ?: emptySet()
    val isSelectedApp=pkg in selected
    val supportedBrowser=pkg in setOf("com.android.chrome","com.sec.android.app.sbrowser","org.mozilla.firefox","com.microsoft.emmx")
    val isInstagramWeb=supportedBrowser && Regex("(?i)(^|\\W)(www\\.)?instagram\\.com([/:?\\s]|$)").containsMatchIn(text)
    if((isSelectedApp||isInstagramWeb)&&now-lastRedirect>1200L){lastRedirect=now;val i=Intent(this,BlockedActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP);startActivity(i)}
  }
  private fun scheduleBoundaryCheck() {
    handler.removeCallbacksAndMessages(null)
    val expiry=prefs.getLong("expiresAt",0L); val bypass=prefs.getLong("bypassUntil",0L); val now=System.currentTimeMillis()
    val next=listOf(expiry,bypass).filter{it>now}.minOrNull() ?: return
    handler.postDelayed({ val activePkg=try{rootInActiveWindow?.packageName?.toString()}catch(_:Exception){null};if(activePkg!=null){val fake=AccessibilityEvent.obtain(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED);val visible=collectVisibleText(fake);fake.recycle();evaluate(activePkg,visible)};scheduleBoundaryCheck() },(next-now+250).coerceAtLeast(250))
  }
  override fun onInterrupt() {}
  override fun onDestroy(){handler.removeCallbacksAndMessages(null);super.onDestroy()}
}
