import 'package:flutter/material.dart';
import '../widgets/reboot_ui.dart';
import 'password_screen.dart';

class DurationScreen extends StatefulWidget {
  final String serviceName;
  const DurationScreen({super.key,required this.serviceName});
  @override State<DurationScreen> createState()=>_DurationScreenState();
}
class _DurationScreenState extends State<DurationScreen>{int selected=7;static const options=[1,3,7,14,30];
  @override Widget build(BuildContext context)=>RebootScaffold(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(20,12,20,0),child:Row(children:[const RebootBackButton(),const SizedBox(width:14),const Text('Choose duration',style:TextStyle(fontSize:16,fontWeight:FontWeight.w800))])),
    Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(22,30,22,24),children:[
      const RebootEyebrow('Step 2 of 4'),const SizedBox(height:13),Text('How long for\nyour ${widget.serviceName} break?',style:const TextStyle(fontSize:30,height:1.1,fontWeight:FontWeight.w800,letterSpacing:-.9)),const SizedBox(height:12),const Text('Choose a timeframe that feels challenging but achievable. You can build up over time.',style:TextStyle(color:RebootColors.muted,fontSize:14,height:1.55)),const SizedBox(height:27),
      ...options.map((d)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_durationTile(d))),
      const SizedBox(height:12),RebootCard(color:const Color(0xFF201E32),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.lightbulb_outline_rounded,color:RebootColors.mint),const SizedBox(width:12),const Expanded(child:Text('A 7-day reset is a good place to start. The goal is consistency, not perfection.',style:TextStyle(color:RebootColors.muted,fontSize:12,height:1.5)))])),
      const SizedBox(height:25),RebootPrimaryButton(label:'Continue',icon:Icons.arrow_forward_rounded,onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>PasswordScreen(serviceName:widget.serviceName,days:selected)))),
    ])),
  ]));
  Widget _durationTile(int days){final active=selected==days;final label=days==1?'24 hours':'$days days';final subtitle=days==1?'A gentle reset':days==3?'A long weekend':days==7?'Build a new rhythm':days==14?'Make space for a habit':'A deeper digital reset';return InkWell(onTap:()=>setState(()=>selected=days),borderRadius:BorderRadius.circular(18),child:AnimatedContainer(duration:const Duration(milliseconds:160),padding:const EdgeInsets.symmetric(horizontal:17,vertical:15),decoration:BoxDecoration(color:active?const Color(0xFF282342):RebootColors.panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:active?RebootColors.purple:RebootColors.line,width:active?1.4:1)),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:active?RebootColors.purple.withValues(alpha:.2):RebootColors.panel2,borderRadius:BorderRadius.circular(13)),child:Icon(Icons.hourglass_bottom_rounded,color:active?RebootColors.purple:RebootColors.muted)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(subtitle,style:const TextStyle(color:RebootColors.muted,fontSize:11))])),Icon(active?Icons.radio_button_checked_rounded:Icons.radio_button_off_rounded,color:active?RebootColors.purple:RebootColors.muted)])));}
}
