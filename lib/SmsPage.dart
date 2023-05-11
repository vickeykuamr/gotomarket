import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HomePage.dart';

class SendSms extends StatefulWidget {
  final phoneNumber;
  const SendSms({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<SendSms> createState() => _SendSmsState();
}

class _SendSmsState extends State<SendSms> {

  var textFieldController=TextEditingController();

  String? selectSms;
  var templateSms = ['--Select--','Agent Allotment','Deal Verified', 'Proposal sent','Deal Lost', 'Order Win','OutCall missed','Payment Link','No Template'];

  void sendingSms(String msg, List<String> listReceipents) async {
    log('message');
    String sendResult = await sendSMS(message: msg, recipients: listReceipents)
        .catchError((err) {
      if (kDebugMode) {
        print(err);
      }
    });
    if (kDebugMode) {
      print(sendResult);
    }
  }

  _launchSms(var number, String msg) async {
try {
if (Platform.isAndroid) {
String uri = 'sms:$number?body=${Uri.encodeComponent(msg)}';
await launchUrl(Uri.parse(uri),mode: LaunchMode.externalApplication);
} else if (Platform.isIOS) {
String uri = 'sms:$number&body=${Uri.encodeComponent(msg)}';
await launchUrl(Uri.parse(uri));
}
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Some error occurred. Please try again! $number'),
),
);
}
}

@override
  void dispose() {
  textFieldController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(foregroundColor: Colors.orange[900],
        title: const Text("Send SMS"),
        centerTitle: true,
        actions: [
          SizedBox(width: 80,child: logo),
          const SizedBox(width: 10,)
        ],
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            // padding: EdgeInsets.only(bottom: 30),
          //  height: 700,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
              boxShadow:const [
                 BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Customer No :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5,),
                  Container(width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 10),
                      decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange)
                  ),
                      child: Text(widget.phoneNumber.toString())),
                  const SizedBox(height: 20,),
                  const Text("Template :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
                  const SizedBox(height: 5,),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                        border: const Border.fromBorderSide(BorderSide(color: Colors.orange))
                    ),
                    child:DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text("--Select--"),
                        ),
                        value: selectSms,
                        items: templateSms.map((templateSms) {
                          return DropdownMenuItem<String>( value: templateSms,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(templateSms),
                              )
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectSms = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text("Message :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: double.infinity,
                   // height: 200,
                    child: TextField(
                      controller: textFieldController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: const BorderSide(color:Colors.orange)) ,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),borderSide: const BorderSide(color:Colors.orange))
                        )),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style:OutlinedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.orange
                        ),
                        onPressed: (){
                          _launchSms(widget.phoneNumber,textFieldController.text.trim());
                          //sending_SMS('Hello, this the test message', ['9918123112',]);
                        }, child: const Text("Send sms",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 23),),),

                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}