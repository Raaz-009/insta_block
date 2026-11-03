package com.example.mynewapp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.util.concurrent.atomic.AtomicBoolean

class InstagramVpnService : VpnService() {
  companion object { const val ACTION_START = "com.reboot.START_VPN"; @Volatile var running = false }
  private var tun: ParcelFileDescriptor? = null
  private val alive = AtomicBoolean(false)
  private val dnsIp = "10.111.0.1"
  private val blocked = setOf("instagram.com", "www.instagram.com", "m.instagram.com", "i.instagram.com", "graph.instagram.com", "cdninstagram.com", "www.cdninstagram.com")

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    val expiry = getSharedPreferences("reboot_blocking", MODE_PRIVATE).getLong("expiresAt", 0L)
    if (expiry <= System.currentTimeMillis()) { stopSelf(); return START_NOT_STICKY }
    if (!alive.get()) startTunnel()
    return START_STICKY
  }
  private fun startTunnel() {
    val channelId = "reboot_protection"
    if (Build.VERSION.SDK_INT >= 26) { val nm = getSystemService(NotificationManager::class.java); nm.createNotificationChannel(NotificationChannel(channelId, "Reboot protection", NotificationManager.IMPORTANCE_LOW)) }
    val notification: Notification = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, channelId).setContentTitle("Reboot protection active").setContentText("Filtering Instagram domains").setSmallIcon(android.R.drawable.ic_lock_lock).build() else Notification.Builder(this).setContentTitle("Reboot protection active").setSmallIcon(android.R.drawable.ic_lock_lock).build()
    startForeground(43, notification)
    tun = Builder().setSession("Reboot Instagram filter").addAddress("10.111.0.2", 32).addDnsServer(dnsIp).addRoute(dnsIp, 32).setMtu(1500).establish()
    if (tun == null) { stopSelf(); return }
    alive.set(true); running = true
    val expiry = getSharedPreferences("reboot_blocking", MODE_PRIVATE).getLong("expiresAt", 0L)
    Handler(Looper.getMainLooper()).postDelayed({
      if (System.currentTimeMillis() >= expiry) stopSelf()
    }, (expiry - System.currentTimeMillis()).coerceAtLeast(0L))
    Thread { packetLoop() }.start()
  }
  private fun packetLoop() {
    val input = FileInputStream(tun!!.fileDescriptor); val output = FileOutputStream(tun!!.fileDescriptor); val packet = ByteArray(32767)
    while (alive.get()) {
      try {
        val n = input.read(packet); if (n < 28) continue
        val ihl = (packet[0].toInt() and 15) * 4
        if ((packet[9].toInt() and 255) != 17 || n < ihl + 8) continue
        val srcPort = u16(packet, ihl); val dstPort = u16(packet, ihl + 2)
        if (dstPort != 53) continue
        val dnsStart = ihl + 8; val dnsLen = n - dnsStart
        val query = packet.copyOfRange(dnsStart, n)
        val domain = readQName(query)
        val response = if (domain != null && isBlocked(domain)) blockedResponse(query) else forwardDns(query)
        val out = ByteArray(ihl + 8 + response.size)
        System.arraycopy(packet, 0, out, 0, ihl)
        // Swap IPv4 addresses.
        for (i in 0..3) { out[12+i] = packet[16+i]; out[16+i] = packet[12+i] }
        out[2] = ((out.size shr 8) and 255).toByte(); out[3] = (out.size and 255).toByte()
        out[6] = 0; out[7] = 0; out[10] = 0; out[11] = 0
        var sum = 0
        var k = 0
        while (k < ihl) { sum += ((out[k].toInt() and 255) shl 8) or (out[k+1].toInt() and 255); k += 2 }
        while ((sum shr 16) != 0) sum = (sum and 0xffff) + (sum shr 16)
        put16(out, 10, sum.inv() and 0xffff)
        put16(out, ihl, 53); put16(out, ihl+2, srcPort); put16(out, ihl+4, 8 + response.size); put16(out, ihl+6, 0)
        System.arraycopy(response, 0, out, ihl+8, response.size)
        output.write(out)
      } catch (_: Exception) { if (!alive.get()) break }
    }
  }
  private fun readQName(d: ByteArray): String? = try { var p=12; val labels= mutableListOf<String>(); while (p<d.size) { val len=d[p++].toInt() and 255; if(len==0) break; if(len>63 || p+len>d.size) return null; labels.add(String(d,p,len,Charsets.US_ASCII)); p+=len }; labels.joinToString(".").lowercase() } catch (_: Exception) { null }
  private fun isBlocked(name: String) = blocked.any { name == it || name.endsWith(".$it") }
  private fun blockedResponse(q: ByteArray): ByteArray { val r=q.copyOf(); if(r.size>=12){ r[2]=0x81.toByte(); r[3]=0x83.toByte(); r[6]=0; r[7]=0; r[8]=0; r[9]=0; r[10]=0; r[11]=0 }; return r }
  private fun forwardDns(q: ByteArray): ByteArray { val socket=DatagramSocket(); return try { protect(socket); socket.soTimeout=2500; val addr=InetAddress.getByName("1.1.1.1"); socket.send(DatagramPacket(q,q.size,addr,53)); val b=ByteArray(4096); val p=DatagramPacket(b,b.size); socket.receive(p); b.copyOf(p.length) } catch (_:Exception) { servFailResponse(q) } finally { socket.close() } }
  private fun servFailResponse(q:ByteArray):ByteArray { val r=q.copyOf(); if(r.size>=12){ r[2]=0x81.toByte(); r[3]=0x82.toByte(); r[6]=0; r[7]=0; r[8]=0; r[9]=0; r[10]=0; r[11]=0 }; return r }
  private fun u16(b:ByteArray,p:Int)=((b[p].toInt() and 255) shl 8) or (b[p+1].toInt() and 255)
  private fun put16(b:ByteArray,p:Int,v:Int){ b[p]=(v shr 8).toByte(); b[p+1]=v.toByte() }
  override fun onDestroy(){ alive.set(false); running=false; try{tun?.close()}catch(_:Exception){}; tun=null; super.onDestroy() }
}
