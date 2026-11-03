import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lock.dart';
import '../services/lock_manager.dart';
import '../widgets/reboot_ui.dart';
import 'home_screen.dart';

class LockedScreen extends StatefulWidget {
  final String lockId;
  const LockedScreen({super.key,required this.lockId});
  @override State<LockedScreen> createState()=>_LockedScreenState();
}
class _LockedScreenState extends State<LockedScreen>{Timer? ticker;bool revealed=false;
  Lock? get currentLock=>lockManager.getLockById(widget.lockId);
  @override void initState(){super.initState();ticker=Timer.periodic(const Duration(seconds:1),(_){if(mounted)setState((){});});}
  @override void dispose(){ticker?.cancel();super.dispose();}
  String _format(Duration d){final days=d.inDays,hours=d.inHours%24,minutes=d.inMinutes%60,seconds=d.inSeconds%60;return '${days.toString().padLeft(2,'0')} : ${hours.toString().padLeft(2,'0')} : ${minutes.toString().padLeft(2,'0')} : ${seconds.toString().padLeft(2,'0')}';}
  void _home()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const HomeScreen()),(_)=>false);
  Future<void> _copy(Lock lock)async{await Clipboard.setData(ClipboardData(text:lock.password));if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Password copied to clipboard')));}
  Future<void> _finish()async{await lockManager.removeLock(widget.lockId);if(!mounted)return;_home();}
  @override Widget build(BuildContext context){final lock=currentLock;if(lock==null)return RebootScaffold(child:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.search_off_rounded,size:48,color:RebootColors.muted),const SizedBox(height:15),const Text('Commitment not found',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:15),RebootPrimaryButton(label:'Back to home',onPressed:_home)])));
    final expired=lock.isExpired;final total=lock.expiresAt.difference(lock.startedAt).inSeconds;final left=lock.remaining.inSeconds;final progress=expired?1.0:(total<=0?0.0:((total-left)/total).clamp(0.0,1.0));
    return RebootScaffold(child:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(20,12,20,0),child:Row(children:[IconButton(onPressed:_home,icon:const Icon(Icons.arrow_back_rounded),style:IconButton.styleFrom(backgroundColor:RebootColors.panel)),const SizedBox(width:12),Expanded(child:Text(lock.serviceName,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800))),Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),decoration:BoxDecoration(color:expired?RebootColors.mint.withValues(alpha:.12):RebootColors.purple.withValues(alpha:.12),borderRadius:BorderRadius.circular(20)),child:Text(expired?'COMPLETED':'IN PROGRESS',style:TextStyle(color:expired?RebootColors.mint:RebootColors.purple,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1)))])),
      Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(22,35,22,28),children:[
        Center(child:SizedBox(width:206,height:206,child:Stack(alignment:Alignment.center,children:[SizedBox.expand(child:CircularProgressIndicator(value:progress,strokeWidth:7,backgroundColor:Colors.white.withValues(alpha:.07),valueColor:AlwaysStoppedAnimation(expired?RebootColors.mint:RebootColors.purple),strokeCap:StrokeCap.round)),Container(width:164,height:164,decoration:BoxDecoration(shape:BoxShape.circle,color:RebootColors.panel,border:Border.all(color:RebootColors.line)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(expired?Icons.lock_open_rounded:Icons.lock_rounded,color:expired?RebootColors.mint:RebootColors.purple,size:29),const SizedBox(height:9),Text(expired?'You did it':'Stay the course',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(expired?'100%':'${(progress*100).round()}%',style:const TextStyle(color:RebootColors.muted,fontSize:11))]))]))),
        const SizedBox(height:30),Center(child:Text(expired?'Your reset is complete':'Your commitment is active',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800,letterSpacing:-.7))),const SizedBox(height:9),Center(child:Text(expired?'You made space for something different.':'You’re choosing your time over the scroll. Keep going.',textAlign:TextAlign.center,style:const TextStyle(color:RebootColors.muted,fontSize:13,height:1.5))),const SizedBox(height:28),
        if(!expired)...[
          RebootCard(child:Column(children:[const RebootEyebrow('TIME REMAINING'),const SizedBox(height:14),FittedBox(fit:BoxFit.scaleDown,child:Text(_format(lock.remaining),style:const TextStyle(fontSize:27,fontWeight:FontWeight.w800,letterSpacing:1.1))),const SizedBox(height:9),const Text('DAYS       HOURS      MINUTES   SECONDS',style:TextStyle(color:RebootColors.muted,fontSize:8,fontWeight:FontWeight.w700,letterSpacing:1))])),const SizedBox(height:17),
          RebootCard(color:const Color(0xFF1A2025),child:const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.favorite_border_rounded,color:RebootColors.mint,size:20),SizedBox(width:11),Expanded(child:Text('The urge to check will pass. Give yourself a few minutes, take a breath, and return to what you meant to do.',style:TextStyle(color:RebootColors.muted,fontSize:12,height:1.55)))])),const SizedBox(height:22),OutlinedButton(onPressed:_home,style:OutlinedButton.styleFrom(foregroundColor:RebootColors.text,side:const BorderSide(color:RebootColors.line),minimumSize:const Size.fromHeight(54),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17))),child:const Text('Back to dashboard')),
        ] else ...[
          RebootCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const RebootEyebrow('YOUR PASSWORD IS READY'),const SizedBox(height:13),Text(revealed?lock.password:'••••••••••••••••••••',textAlign:TextAlign.center,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800,letterSpacing:1.1)),const SizedBox(height:15),if(!revealed)RebootPrimaryButton(label:'Reveal my password',icon:Icons.visibility_outlined,onPressed:()=>setState(()=>revealed=true))else OutlinedButton.icon(onPressed:()=>_copy(lock),icon:const Icon(Icons.copy_rounded),label:const Text('Copy password'),style:OutlinedButton.styleFrom(foregroundColor:RebootColors.mint,minimumSize:const Size.fromHeight(50),side:BorderSide(color:RebootColors.mint.withValues(alpha:.35)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))))])),const SizedBox(height:16),RebootPrimaryButton(label:'Finish reset',icon:Icons.check_rounded,onPressed:_finish),const SizedBox(height:9),const Text('Take a moment to decide how you want to use the app differently this time.',textAlign:TextAlign.center,style:TextStyle(color:RebootColors.muted,fontSize:11,height:1.5)),
        ],
      ])),
    ]));
  }
}
