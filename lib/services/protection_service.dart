import 'package:flutter/services.dart';
class ProtectionService {
 static const _channel=MethodChannel('com.reboot/blocking');
 Future<List<Map<String,String>>> getInstalledApps() async { final r=await _channel.invokeListMethod<dynamic>('getInstalledApps')??[]; return r.map((e){final m=Map<String,dynamic>.from(e as Map);return {'name':'${m['name']??m['packageName']}','packageName':'${m['packageName']}'};}).toList(); }
 Future<Map<String,dynamic>> start(String sessionId,DateTime expiry,List<String> packages) async => (await _channel.invokeMapMethod<String,dynamic>('startProtection',{'sessionId':sessionId,'expiresAt':expiry.millisecondsSinceEpoch,'packages':packages}))??{};
 Future<void> stop()=>_channel.invokeMethod<void>('stopProtection');
 Future<void> openAccessibilitySettings()=>_channel.invokeMethod<void>('openAccessibilitySettings');
 Future<Map<String,dynamic>> status() async => (await _channel.invokeMapMethod<String,dynamic>('getProtectionStatus'))??{};
 Future<void> storePassword(String key,String password)=>_channel.invokeMethod<void>('storePassword',{'key':key,'password':password});
 Future<String?> revealPassword(String key)=>_channel.invokeMethod<String>('revealPassword',{'key':key});
 Future<void> deletePassword(String key)=>_channel.invokeMethod<void>('deletePassword',{'key':key});
}
final protectionService=ProtectionService();
