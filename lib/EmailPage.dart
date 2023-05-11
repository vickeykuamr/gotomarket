import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'HomePage.dart';


class SendEmail extends StatefulWidget {
  const SendEmail({Key? key}) : super(key: key);

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  String? sendmail;
  var templateEmail = ['Agent Allotment', 'Lead Verified', 'Proposal Sent', 'Deal Lost', 'OutCall Missed','Deal won','No Template'];

  var file;

  void _pickFile() async {

    // for multiple selection
    // List<File> files = filePickerResult.paths.map((path) => File(path!)).toList();
    // Uint8List  bytes = await  files[0].readAsBytes();
    //
    // log("kkkkkkl "+bytes.toString());

    // for single selection'
    final result = await FilePicker.platform.pickFiles(allowMultiple: false,);
    if (result == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Cancelled')));
      return;
    } else{
      file=result.files.single;
    }

    setState(() {
      // fileName=result.files.first.name;
      // file = result.files.first;
    });
  }

  void _openFile(PlatformFile file) {
    OpenFile.open(file.path!);
  }

  void viewFile(){
    log(file.toString());
    showDialog(context: context, builder: (BuildContext ctx){
      return AlertDialog(
        content: Row(
          children: [
            TextButton(onPressed: (){
             Navigator.pop(context);
              _openFile(file);
            }, child: const Text('View File')),
            TextButton(onPressed: (){
              Navigator.pop(context);
              setState(() {
                file='null';
              });
            }, child: const Text('Remove File')),
          ],
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(foregroundColor: Colors.orange[900],
        title: const Text("Send Mail"),centerTitle: true,
      actions: [  SizedBox(width: 80,child: logo),
        const SizedBox(width: 10,)
      ],),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            // padding: EdgeInsets.only(bottom: 30),
            //height: 550,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               // const SizedBox(height: 40,),
               //  const Padding(
               //    padding: EdgeInsets.all(8.0),
               //    child: Text("Send Email :",style:TextStyle(fontSize: 25,fontWeight:FontWeight.w400)),
               //  ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("E-Mail Id :",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),),
                      const SizedBox(height: 4,),
                      Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                          width: double.infinity,
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
                          )),
                      const SizedBox(height: 10,),
                      const Text("Subject :",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20)),
                      const SizedBox(height: 4,),
                      Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                          width: double.infinity,
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))),
                          )),
                      const SizedBox(height: 10,),
                      const Text("Template :",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20)),
                      const SizedBox(height: 4,),
                      Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                              border: const Border.fromBorderSide(BorderSide(color: Colors.grey))
                          ),
                          width: double.infinity,
                          height: 50,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              hint: const Text("  -- Select --"),
                              value: sendmail,
                              items: templateEmail.map((templateEmail){
                                return DropdownMenuItem<String>(
                                    value: templateEmail,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(templateEmail),
                                    )
                                );
                              }).toList(),
                              onChanged: (value){
                                setState(() {
                                  sendmail = value!;
                                });
                              },
                            ),
                          )
                      ),
                      const SizedBox(height: 10,),
                      const Text("Attachment :",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20)),
                      const SizedBox(height: 4,),
                      Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                              border: const Border.fromBorderSide(BorderSide(color: Colors.grey))),
                          width: double.infinity,
                          height: 50,
                          child:Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: OutlinedButton(style: OutlinedButton.styleFrom(
                                    backgroundColor:mColor),
                                    onPressed: (){
                                      _pickFile();
                                    }, child: const Text("Choose File")),
                              ),
                               Expanded(child:file==null?const Text('No Chosen File'): InkWell(onTap:(){_openFile(file);},child: Text(file.name,maxLines: 1,overflow: TextOverflow.ellipsis,))),
                              Text(file==null?"":file.extension),
                              const SizedBox(width: 4,),
                            ],
                          )
                      ),
                      const SizedBox(height: 10,),
                      const Text("Message :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
                      const SizedBox(height: 4,),
                      SizedBox(
                        width: double.infinity,
                       // height: 200,
                        child: TextField(
                            maxLines: 6,
                            decoration: InputDecoration(border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),borderSide: const BorderSide(color: Colors.grey))
                            )
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                              style:OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: mColor
                              ),
                              onPressed: (){
                              }, child: const Text("Send Mail",style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 23
                          ),)),
                       //   const SizedBox(width: 30,),
                          // OutlinedButton(
                          //     style:OutlinedButton.styleFrom(
                          //         backgroundColor: Colors.grey,
                          //         primary: Colors.black
                          //     ),
                          //     onPressed: (){}, child: const Text("Cancel",style: TextStyle(
                          //     fontWeight: FontWeight.w400,
                          //     fontSize: 23
                          // ),))
                        ],)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}