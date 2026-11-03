import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lock.dart';
import '../services/lock_manager.dart';
import '../services/protection_service.dart';
import '../widgets/reboot_ui.dart';
import 'choose_service_screen.dart';
import 'locked_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  @override
  void initState() { super.initState(); _ticker = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); }); }
  @override
  void dispose() { _ticker?.cancel(); super.dispose(); }
  Future<void> _createLock() async { if (lockManager.activeLocks.isNotEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finish your active commitment before starting another one.'))); return; } await Navigator.push(context, MaterialPageRoute(builder: (_) => const ChooseServiceScreen())); if (mounted) setState(() {}); }
  Future<void> _openLock(Lock lock) async { await Navigator.push(context, MaterialPageRoute(builder: (_) => LockedScreen(lockId: lock.id))); if (mounted) setState(() {}); }
  String _remaining(Duration d) { if (d <= Duration.zero) return 'Completed'; final days=d.inDays, hours=d.inHours%24, minutes=d.inMinutes%60; if(days>0)return '${days}d ${hours}h left'; if(hours>0)return '${hours}h ${minutes}m left'; return '${minutes}m ${d.inSeconds%60}s left'; }

  @override
  Widget build(BuildContext context) {
    final active=lockManager.activeLocks; final completed=lockManager.locks.where((l)=>l.isExpired).length;
    return RebootScaffold(child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(22,14,22,30), sliver: SliverList(delegate: SliverChildListDelegate([
        Row(children: [Container(width:38,height:38,decoration:BoxDecoration(borderRadius:BorderRadius.circular(13),gradient:const LinearGradient(colors:[RebootColors.purple,RebootColors.mint])),child:const Icon(Icons.spa_rounded,color:Color(0xFF10111A),size:22)),const SizedBox(width:11),const Text('reboot',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,letterSpacing:-.7)),const Spacer(),IconButton(onPressed:()=>_showAbout(context),icon:const Icon(Icons.tune_rounded,color:RebootColors.muted),style:IconButton.styleFrom(backgroundColor:RebootColors.panel))]),
        const SizedBox(height:32), const RebootEyebrow('A little space goes a long way'), const SizedBox(height:12),
        const Text('Make room for\nwhat matters.',style:TextStyle(fontSize:37,height:1.05,fontWeight:FontWeight.w800,letterSpacing:-1.5)),const SizedBox(height:12),
        const Text('Step away from the scroll. Give your time and attention back to yourself.',style:TextStyle(color:RebootColors.muted,fontSize:14,height:1.55)),const SizedBox(height:25),
        _heroCard(active.length,completed),const SizedBox(height:24),
        GestureDetector(onTap:_createLock,child:Container(padding:const EdgeInsets.symmetric(horizontal:19,vertical:18),decoration:BoxDecoration(color:RebootColors.purple,borderRadius:BorderRadius.circular(20),boxShadow:[BoxShadow(color:RebootColors.purple.withValues(alpha:.18),blurRadius:24,offset:const Offset(0,10))]),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:const Color(0xFF7566E9),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.add_rounded,color:Colors.white,size:25)),const SizedBox(width:13),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Create a new break',style:TextStyle(color:Color(0xFF10111A),fontSize:16,fontWeight:FontWeight.w800)),SizedBox(height:3),Text('Choose apps and set a commitment',style:TextStyle(color:Color(0xCC10111A),fontSize:12))])),const Icon(Icons.arrow_forward_rounded,color:Color(0xFF10111A))]))),
        const SizedBox(height:30),Row(children:[const Expanded(child:Text('Your commitments',style:TextStyle(fontSize:19,fontWeight:FontWeight.w800,letterSpacing:-.4))),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),decoration:BoxDecoration(color:RebootColors.panel2,borderRadius:BorderRadius.circular(20)),child:Text('${active.length} active',style:const TextStyle(color:RebootColors.mint,fontSize:11,fontWeight:FontWeight.w700)))]),const SizedBox(height:13),
        if(active.isEmpty)_emptyState(_createLock) else ...active.map((lock)=>Padding(padding:const EdgeInsets.only(bottom:11),child:_CommitmentCard(lock:lock,remaining:_remaining(lock.remaining),onTap:()=>_openLock(lock)))),
        const SizedBox(height:20),const Center(child:Text('Small choices. Meaningful change.',style:TextStyle(color:Color(0xFF626779),fontSize:11,letterSpacing:.3))),
      ]))),
    ]));
  }

  Widget _heroCard(int active,int completed)=>Container(width:double.infinity,padding:const EdgeInsets.all(19),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF282342),Color(0xFF191D2C)]),border:Border.all(color:RebootColors.purple.withValues(alpha:.24))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.nights_stay_rounded,color:RebootColors.mint,size:18),const SizedBox(width:8),const Text('YOUR RESET SPACE',style:TextStyle(color:Color(0xFFB9B2E8),fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.4)),const Spacer(),Container(width:7,height:7,decoration:const BoxDecoration(color:RebootColors.mint,shape:BoxShape.circle)),const SizedBox(width:6),const Text('Ready when you are',style:TextStyle(color:RebootColors.mint,fontSize:10,fontWeight:FontWeight.w600))]),const SizedBox(height:22),const Text('Your next chapter\nstarts offline.',style:TextStyle(fontSize:24,height:1.12,fontWeight:FontWeight.w800,letterSpacing:-.6)),const SizedBox(height:18),Row(children:[_miniStat('$active','Active breaks'),const SizedBox(width:25),Container(width:1,height:32,color:Colors.white12),const SizedBox(width:25),_miniStat('$completed','Completed')]) ]));
  Widget _miniStat(String value,String label)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:2),Text(label,style:const TextStyle(color:RebootColors.muted,fontSize:11))]);
  Widget _emptyState(VoidCallback onCreate)=>RebootCard(padding:const EdgeInsets.symmetric(horizontal:20,vertical:25),child:Column(children:[Container(width:54,height:54,decoration:BoxDecoration(color:RebootColors.purple.withValues(alpha:.12),shape:BoxShape.circle),child:const Icon(Icons.self_improvement_rounded,color:RebootColors.purple,size:27)),const SizedBox(height:13),const Text('Nothing to reset just yet',style:TextStyle(fontSize:15,fontWeight:FontWeight.w700)),const SizedBox(height:6),const Text('Your active commitments will appear here. Start with one small change.',textAlign:TextAlign.center,style:TextStyle(color:RebootColors.muted,fontSize:12,height:1.5)),const SizedBox(height:15),TextButton(onPressed:onCreate,child:const Text('Set your first commitment'))]));
  void _showAbout(BuildContext context) => showModalBottomSheet(
    context: context,
    backgroundColor: RebootColors.panel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reboot settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text(
            'Enable Android Accessibility so Reboot can detect the apps you select and supported Instagram URLs in browsers. No VPN connection is used.',
            style: TextStyle(color: RebootColors.muted, height: 1.55),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await protectionService.openAccessibilitySettings();
              },
              icon: const Icon(Icons.accessibility_new_rounded),
              label: const Text('Enable app blocking'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Browser URL detection is best-effort and depends on what the browser exposes to Android Accessibility.',
            style: TextStyle(color: RebootColors.muted, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    ),
  );
}

class _CommitmentCard extends StatelessWidget {
  final Lock lock;final String remaining;final VoidCallback onTap;
  const _CommitmentCard({required this.lock,required this.remaining,required this.onTap});
  @override Widget build(BuildContext context){final total=lock.expiresAt.difference(lock.startedAt).inSeconds;final elapsed=DateTime.now().difference(lock.startedAt).inSeconds;final progress=total<=0?0.0:(elapsed/total).clamp(0.0,1.0);return Material(color:Colors.transparent,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(21),child:RebootCard(child:Column(children:[Row(children:[Container(width:43,height:43,decoration:BoxDecoration(color:RebootColors.purple.withValues(alpha:.13),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.lock_clock_rounded,color:RebootColors.purple)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(lock.serviceName,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15)),const SizedBox(height:3),const Text('App blocking commitment',style:TextStyle(color:RebootColors.muted,fontSize:11))])),const Icon(Icons.chevron_right_rounded,color:RebootColors.muted)]),const SizedBox(height:17),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('TIME TO GO',style:TextStyle(color:RebootColors.muted,fontSize:9,fontWeight:FontWeight.w800,letterSpacing:1.3)),Text(remaining,style:const TextStyle(color:RebootColors.mint,fontSize:12,fontWeight:FontWeight.w700))]),const SizedBox(height:9),RebootProgress(value:progress)]))));}
}
