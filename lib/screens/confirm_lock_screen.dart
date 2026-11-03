import 'package:flutter/material.dart';
import '../services/lock_manager.dart';
import '../widgets/reboot_ui.dart';
import 'locked_screen.dart';

class ConfirmLockScreen extends StatelessWidget {
  final String serviceName,password;final int days;
  const ConfirmLockScreen({super.key,required this.serviceName,required this.password,required this.days});
  @override Widget build(BuildContext context)=>RebootScaffold(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(20,12,20,0),child:Row(children:[const RebootBackButton(),const SizedBox(width:14),const Text('Review commitment',style:TextStyle(fontSize:16,fontWeight:FontWeight.w800))])),
    Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(22,35,22,28),children:[
      const Center(child:CircleAvatar(radius:43,backgroundColor:Color(0xFF282342),child:Icon(Icons.lock_rounded,size:36,color:RebootColors.purple))),const SizedBox(height:25),const RebootEyebrow('Step 4 of 4'),const SizedBox(height:12),const Text('Make this promise\nto yourself.',textAlign:TextAlign.center,style:TextStyle(fontSize:31,height:1.08,fontWeight:FontWeight.w800,letterSpacing:-.9)),const SizedBox(height:12),Text('You’re about to begin a $days-day break from $serviceName. Take a moment and make sure you’re ready.',textAlign:TextAlign.center,style:const TextStyle(color:RebootColors.muted,fontSize:14,height:1.55)),const SizedBox(height:28),
      RebootCard(child:Column(children:[_summaryRow(Icons.apps_rounded,'Service',serviceName),const Divider(height:25,color:RebootColors.line),_summaryRow(Icons.calendar_today_rounded,'Commitment','$days ${days==1?'day':'days'}'),const Divider(height:25,color:RebootColors.line),_summaryRow(Icons.key_rounded,'Password','Hidden until completion')])),const SizedBox(height:15),
      RebootCard(color:const Color(0xFF28231C),border:Border.all(color:RebootColors.amber.withValues(alpha:.22)),child:const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.info_outline_rounded,color:RebootColors.amber,size:19),SizedBox(width:11),Expanded(child:Text('Android will request VPN approval when you begin. App-launch blocking also requires Reboot to be enabled in Accessibility settings.',style:TextStyle(color:Color(0xFFD5C6AE),fontSize:12,height:1.5)))])),const SizedBox(height:25),
      RebootPrimaryButton(label:'Start my commitment',icon:Icons.lock_outline_rounded,onPressed:()async{await lockManager.startLock(serviceName:serviceName,password:password,days:days);if(!context.mounted)return;final warning=lockManager.lastProtectionError;final lock=lockManager.locks.last;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>LockedScreen(lockId:lock.id)));if(warning!=null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Commitment saved, but VPN protection was not enabled. Check Android permissions in Reboot settings.')));}}),const SizedBox(height:12),TextButton(onPressed:()=>Navigator.pop(context),child:const Text('I need to make a change')),
    ])),
  ]));
  Widget _summaryRow(IconData icon,String label,String value)=>Row(children:[Icon(icon,color:RebootColors.purple,size:19),const SizedBox(width:12),Expanded(child:Text(label,style:const TextStyle(color:RebootColors.muted,fontSize:12))),Text(value,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700))]);
}
