import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lock.dart';
import 'protection_service.dart';
class LockManager {
 List<Lock> _locks=[]; String? lastProtectionError;
 List<Lock> get locks=>List.unmodifiable(_locks);
 List<Lock> get activeLocks=>_locks.where((l)=>!l.isExpired).toList();
 Lock? getLockById(String id){for(final l in _locks){if(l.id==id)return l;}return null;}
 Future<void> startLock({required String serviceName,required List<Map<String,String>> selectedApps,required String? password,required int days}) async {
  final now=DateTime.now(); final id=DateTime.now().microsecondsSinceEpoch.toString(); final key=password==null?null:'reboot_$id';
  if(password!=null) await protectionService.storePassword(key!,password);
  final lock=Lock(id:id,serviceName:serviceName,appNames:selectedApps.map((a)=>a['name']!).toList(),packageNames:selectedApps.map((a)=>a['packageName']!).toList(),passwordKey:key,passwordProtected:password!=null,startedAt:now,expiresAt:now.add(Duration(days:days)));
  _locks.add(lock); await _save(); lastProtectionError=null;
  try { final status=await protectionService.start(lock.id,lock.expiresAt,lock.packageNames); if(status['accessibility']!=true) lastProtectionError='Enable Reboot in Android Accessibility settings to enforce this commitment.'; } catch(e){lastProtectionError=e.toString();}
 }
 Future<void> loadLocks() async {
  final p=await SharedPreferences.getInstance(); final raw=p.getString('locks');
  if(raw==null){await protectionService.stop();return;}
  try {
    final decoded=(jsonDecode(raw) as List).map((e)=>Map<String,dynamic>.from(e)).toList();
    var migrated=false;
    const legacyPackages={'Instagram':'com.instagram.android','TikTok':'com.zhiliaoapp.musically','YouTube':'com.google.android.youtube','Reddit':'com.reddit.frontpage','Discord':'com.discord','X':'com.twitter.android'};
    for(final item in decoded){
      final legacyPassword=item['password'];
      if(legacyPassword is String && legacyPassword.isNotEmpty && item['passwordKey']==null){
        final key='reboot_${item['id']}';
        await protectionService.storePassword(key,legacyPassword);
        item['passwordKey']=key; item['passwordProtected']=true; item.remove('password'); migrated=true;
      }
      if(item['packageNames']==null){final oldName=item['serviceName'] as String?;final pkg=legacyPackages[oldName];item['packageNames']=pkg==null?<String>[]:<String>[pkg];item['appNames']=oldName==null?<String>[]:<String>[oldName];migrated=true;}
    }
    _locks=decoded.map((e)=>Lock.fromJson(e)).toList();
    if(migrated) await _save();
    if(activeLocks.isEmpty){await protectionService.stop();}else{final latest=activeLocks.reduce((a,b)=>a.expiresAt.isAfter(b.expiresAt)?a:b);await protectionService.start(latest.id,latest.expiresAt,activeLocks.expand((l)=>l.packageNames).toSet().toList());}
  } catch(_){_locks=[];}
}
 Future<void> removeLock(String id) async {final old=getLockById(id);_locks.removeWhere((l)=>l.id==id);await _save();if(old?.passwordKey!=null){try{await protectionService.deletePassword(old!.passwordKey!);}catch(_){}}if(activeLocks.isEmpty){await protectionService.stop();}else{final latest=activeLocks.reduce((a,b)=>a.expiresAt.isAfter(b.expiresAt)?a:b);await protectionService.start(latest.id,latest.expiresAt,activeLocks.expand((l)=>l.packageNames).toSet().toList());}}
 Future<void> _save() async {final p=await SharedPreferences.getInstance();await p.setString('locks',jsonEncode(_locks.map((l)=>l.toJson()).toList()));}
}
final lockManager=LockManager();
