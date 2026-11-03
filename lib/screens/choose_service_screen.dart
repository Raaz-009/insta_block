import 'package:flutter/material.dart';
import '../widgets/reboot_ui.dart';
import 'duration_screen.dart';

class ChooseServiceScreen extends StatelessWidget {
  const ChooseServiceScreen({super.key});
  static const _services = <(String, IconData, Color)>[
    ('Instagram', Icons.camera_alt_rounded, Color(0xFFE58AB2)),
    ('TikTok', Icons.music_note_rounded, Color(0xFFB5D9E8)),
    ('YouTube', Icons.play_arrow_rounded, Color(0xFFFF7777)),
    ('Reddit', Icons.forum_rounded, Color(0xFFFFA36C)),
    ('Discord', Icons.headphones_rounded, Color(0xFF9AA9FF)),
    ('X', Icons.close_rounded, Color(0xFFE6E6EA)),
  ];
  void _next(BuildContext context,String service)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>DurationScreen(serviceName:service)));

  @override Widget build(BuildContext context)=>RebootScaffold(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(20,12,20,0),child:Row(children:[const RebootBackButton(),const SizedBox(width:14),const Text('New commitment',style:TextStyle(fontSize:16,fontWeight:FontWeight.w800))])),
    Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(22,30,22,28),children:[
      const RebootEyebrow('Step 1 of 4'),const SizedBox(height:13),const Text('What would you\nlike a break from?',style:TextStyle(fontSize:32,height:1.08,fontWeight:FontWeight.w800,letterSpacing:-1)),const SizedBox(height:12),const Text('Choose the app or service you want to spend less time on.',style:TextStyle(color:RebootColors.muted,fontSize:14,height:1.5)),const SizedBox(height:27),
      ..._services.map((s)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_ServiceTile(name:s.$1,icon:s.$2,tint:s.$3,onTap:()=>_next(context,s.$1)))),
      const SizedBox(height:5),OutlinedButton.icon(onPressed:()=>_custom(context),icon:const Icon(Icons.add_rounded),label:const Text('Add another service'),style:OutlinedButton.styleFrom(foregroundColor:RebootColors.text,side:const BorderSide(color:RebootColors.line),minimumSize:const Size.fromHeight(54),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17)))),
      const SizedBox(height:22),const Center(child:Text('You can create separate commitments for different services.',textAlign:TextAlign.center,style:TextStyle(color:RebootColors.muted,fontSize:11))),
    ])),
  ]));
  void _custom(BuildContext context){final c=TextEditingController();showDialog(context:context,builder:(ctx)=>AlertDialog(backgroundColor:RebootColors.panel,title:const Text('Add a service'),content:TextField(controller:c,autofocus:true,decoration:const InputDecoration(hintText:'e.g. Gaming, streaming...')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),FilledButton(onPressed:(){final name=c.text.trim();if(name.isEmpty)return;Navigator.pop(ctx);_next(context,name);},child:const Text('Continue'))]));}
}

class _ServiceTile extends StatelessWidget {
  final String name;final IconData icon;final Color tint;final VoidCallback onTap;
  const _ServiceTile({required this.name,required this.icon,required this.tint,required this.onTap});
  @override Widget build(BuildContext context)=>Material(color:Colors.transparent,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(19),child:RebootCard(padding:const EdgeInsets.symmetric(horizontal:15,vertical:14),child:Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:tint.withValues(alpha:.13),borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:tint,size:22)),const SizedBox(width:14),Expanded(child:Text(name,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w700))),const Icon(Icons.arrow_forward_ios_rounded,size:14,color:RebootColors.muted)]))));
}
