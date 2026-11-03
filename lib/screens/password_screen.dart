import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/reboot_ui.dart';
import 'confirm_lock_screen.dart';

String generatePassword(){const chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';final random=Random.secure();return List.generate(20,(_)=>chars[random.nextInt(chars.length)]).join();}

class PasswordScreen extends StatefulWidget {
  final String serviceName;final int days;
  const PasswordScreen({super.key,required this.serviceName,required this.days});
  @override State<PasswordScreen> createState()=>_PasswordScreenState();
}
class _PasswordScreenState extends State<PasswordScreen>{late final String password;bool copied=false;bool visible=true;
  @override void initState(){super.initState();password=generatePassword();}
  Future<void> _copy()async{await Clipboard.setData(ClipboardData(text:password));if(!mounted)return;setState(()=>copied=true);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Password copied. Change it on your account before continuing.')));}
  @override Widget build(BuildContext context)=>RebootScaffold(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(20,12,20,0),child:Row(children:[const RebootBackButton(),const SizedBox(width:14),const Text('Create your lock',style:TextStyle(fontSize:16,fontWeight:FontWeight.w800))])),
    Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(22,30,22,25),children:[
      const RebootEyebrow('Step 3 of 4'),const SizedBox(height:13),Text('One last step\nbefore your reset.',style:const TextStyle(fontSize:31,height:1.08,fontWeight:FontWeight.w800,letterSpacing:-.9)),const SizedBox(height:12),Text('Create a new password for ${widget.serviceName}. Reboot will keep it hidden until your commitment ends.',style:const TextStyle(color:RebootColors.muted,fontSize:14,height:1.55)),const SizedBox(height:25),
      RebootCard(padding:const EdgeInsets.all(19),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const Icon(Icons.key_rounded,color:RebootColors.purple,size:19),const SizedBox(width:9),const Text('YOUR NEW PASSWORD',style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.3,color:RebootColors.muted)),const Spacer(),IconButton(onPressed:()=>setState(()=>visible=!visible),icon:Icon(visible?Icons.visibility_off_outlined:Icons.visibility_outlined,color:RebootColors.muted))]),const SizedBox(height:12),SelectableText(visible?password:'•'*password.length,textAlign:TextAlign.center,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800,letterSpacing:1.1,color:RebootColors.text)),const SizedBox(height:17),SizedBox(width:double.infinity,height:48,child:OutlinedButton.icon(onPressed:_copy,icon:Icon(copied?Icons.check_rounded:Icons.copy_rounded),label:Text(copied?'Copied to clipboard':'Copy password'),style:OutlinedButton.styleFrom(foregroundColor:RebootColors.mint,side:BorderSide(color:RebootColors.mint.withValues(alpha:.35)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)))))])),
      const SizedBox(height:14),RebootCard(color:const Color(0xFF28231C),border:Border.all(color:RebootColors.amber.withValues(alpha:.22)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.shield_outlined,color:RebootColors.amber,size:20),const SizedBox(width:12),const Expanded(child:Text('Before you continue, change your account password to this one. Avoid saving it in notes or another password manager you can access during the break.',style:TextStyle(color:Color(0xFFD5C6AE),fontSize:12,height:1.55)))])),
      const SizedBox(height:20),Row(children:[const Icon(Icons.calendar_month_outlined,color:RebootColors.muted,size:17),const SizedBox(width:8),Text('${widget.days} ${widget.days==1?'day':'days'} away from ${widget.serviceName}',style:const TextStyle(color:RebootColors.muted,fontSize:12,fontWeight:FontWeight.w600))]),const SizedBox(height:22),
      RebootPrimaryButton(label:'I’ve changed my password',icon:Icons.arrow_forward_rounded,onPressed:copied?()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ConfirmLockScreen(serviceName:widget.serviceName,password:password,days:widget.days))):null),
      const SizedBox(height:12),const Text('Copy the password, update your account, then continue.',textAlign:TextAlign.center,style:TextStyle(color:RebootColors.muted,fontSize:11)),
    ])),
  ]));
}
