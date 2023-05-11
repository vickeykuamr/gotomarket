import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gm/SessionPage/MySession.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ApiService/BaseUrl.dart';
import '../HomePage.dart';
import '../NotificationPage/MyNotification.dart';

class AddLeads extends StatefulWidget {
  final sourceList;
  final dropdownList;
  const AddLeads({Key? key,required this.sourceList, this.dropdownList}) : super(key: key);

  @override
  State<AddLeads> createState() => _AddLeadsState();
}

class _AddLeadsState extends State<AddLeads> {

  TextEditingController walkIn = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController alternateNo = TextEditingController();
  //TextEditingController product = TextEditingController();
  TextEditingController organization = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  //TextEditingController status = TextEditingController();
  TextEditingController website = TextEditingController();
 // TextEditingController source = TextEditingController();
 // TextEditingController assignedAgent = TextEditingController();
  //TextEditingController indusrtyType = TextEditingController();
  TextEditingController message = TextEditingController();
  TextEditingController description = TextEditingController();

  var dropdownList;

   List<dynamic> leadQualityList = [];
  String? leadQualityValue;

    List<dynamic> productList = [];
  String? productValue;

  final  List<dynamic> statusList = [];
  String? statusSellValue;

    List<dynamic> mySourceList = [];
  String? sourceValue;

  // final  List<dynamic> assignList = [];
  // String? assignValue;

  final  List<dynamic> industryList = [];
  String? industryTypeValue;
  String? assignedAgentName;

  late SharedPreferences sharedPreferences;
  String? getCookies;
  bool isDialog=false;
  bool isSuccess=false;
  bool isError=false;
  bool dropValueLoading=false;
  String? msg;
  var title='';
  var errorDropValue='Loading...';

  Future<void> getSharedPreference()async{
    log('dropppppp '+widget.dropdownList.toString());
    sharedPreferences=await SharedPreferences.getInstance();
    assignedAgentName=sharedPreferences.getString('agentName');
    getCookies= sharedPreferences.getString('cookie');
    print("kkkkk $getCookies");

    if(widget.dropdownList!=null){
      dropValueLoading=true;
      dropdownList=widget.dropdownList;

      var product=dropdownList[0]['dropvalue'];
      var ticketstatus=dropdownList[1]['dropvalue'];
      var source=dropdownList[5]['dropvalue'];
      var priority=dropdownList[3]['dropvalue'];
      var industrytype=dropdownList[4]['dropvalue'];

      productList.addAll(product);
      statusList.addAll(ticketstatus);
      industryList.addAll(industrytype);
      leadQualityList.addAll(priority);
      mySourceList.addAll(source);

setState(() {});
    }else{
     getDropdownValue();
    }
  }

  void showDialogs(){
    showDialog(barrierDismissible: false,
        context: context, builder: (BuildContext context){
      return WillPopScope(
        onWillPop: ()async =>isDialog?true:false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
         // title:isDialog?null:Text(title),
          actions: [

            isDialog?Text(msg!): Container(alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 10,bottom: 10,left: 20.0),
              child:Row(
                //  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 25,height: 25,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2,color: mColor,))),SizedBox(width: 10,),Text('Data Sending...'),
                ],
              ),
            ),

            isDialog?TextButton(onPressed: (){
              if(isError){
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LeadCounterPage()), (route) => false);
              }else{
                Navigator.pop(context);
              }
            }, child: Text('OK',style: TextStyle(color: mColor),)):Container()
          ],
        ),
      );
    });
  }

  void closeDialog(){
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }else{
    //  Navigator.pop(context);
    }
  }

  Future<void> addLeads()async{
    String? leadStatus;
    if(contact.text.isEmpty){
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: const Text('Enter Contact Number',style: TextStyle(color: Colors.white,),),backgroundColor: Colors.orange.shade400,));
    }
    else if(productValue==null){
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: const Text('Choose Any One Product',style: TextStyle(color: Colors.white),),backgroundColor: Colors.orange.shade400,));
    }else if(sourceValue==null){
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: const Text("Choose any One Source",style: TextStyle(color: Colors.white)),backgroundColor: Colors.orange.shade400,));
    }
    else{
      if(statusSellValue==null){
        leadStatus='open';
        log(leadStatus);
      }else{
        leadStatus=statusSellValue.toString();
      }
      try{
        isDialog=false;
        title='Please Wait';
        showDialogs();
        var headers = {
          'Content-Type': 'application/json',
          'cookie':'$getCookies'
        };
        var request = http.Request('POST', Uri.parse('${BaseUrl.apiBaseUrl}/addnewLead'));
        request.body = json.encode({
          "leadId": "",
          "name": firstName.text.trim().toString(),
          "email": emailId.text.trim().toString(),
          "contactNo": contact.text.trim().toString(),
          "alternateNo": alternateNo.text.trim().toString(),
          "address": address.text.trim().toString(),
          "state": state.text.trim().toString(),
          "leadSource": sourceValue.toString(),
          "companyName": organization.text.trim().toString(),
          "leadquality": leadQualityValue.toString(),
          "website": website.text.trim().toString(),
          "industryType": industryTypeValue.toString(),
          "leadStatus": leadStatus.toString(),
          "statusReason":"" ,
          "assignedAgent": assignedAgentName.toString(),
          "timestamp": DateTime.now().toString(),
          "product": productValue.toString(),
          "description": description.text.trim().toString(),
          "sourcename": "",
          "message": message.text.trim().toString(),
          "createdBy": ""
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        log(response.reasonPhrase.toString());
        if (response.statusCode == 200) {
          //showNotification(1, 'title', 'add new lead');
          var res=await response.stream.bytesToString();
          isDialog=true;
          isError=true;
          log(res.toString());
          closeDialog();
          msg='Record Add Successfully';
          showDialogs();
          clearData();
        }
        else {
          isDialog=true;
          closeDialog();
          msg='Failed to Upload Record';
          if(response.reasonPhrase.toString()=='Unauthorized'){
            MySessions.sessionExpire(context);
          }else{
            showDialogs();
            log(response.reasonPhrase.toString());
          }
        }
      }on TimeoutException catch (_) {
        msg="Your connection has timed out";
        isDialog=true;
        closeDialog();
        if(_.toString()=='Unauthorized'){
          MySessions.sessionExpire(context);
        }else{
          showDialogs();
        }
        log(_.toString());
        print("Your connection has timed out");
      }on SocketException catch (_) {
        msg="You are not connected to internet";
        isDialog=true;
        closeDialog();
        if(_.toString()=='Unauthorized'){
         MySessions.sessionExpire(context);
        }else{
          showDialogs();
        }
        log(_.toString());
        print("You are not connected to internet");
      }

      catch(e){
        isDialog=true;
        msg='Network Error Or Server Down';
        closeDialog();
        if(e.toString()=='Unauthorized'){
          MySessions.sessionExpire(context);        }
        showDialogs();
        log(e.toString());
      }
    }
  }

  Future<void> getDropdownValue()async{
    try{
    productList.clear();
      statusList.clear();
      industryList.clear();
      leadQualityList.clear();
      mySourceList.clear();

      var headers = {
        'cookie':'$getCookies'
      };
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/dropdown'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
    log("ssadss "+getCookies.toString());

    if (response.statusCode == 200){

    var result=await response.stream.bytesToString();
    log("ss2222ss "+result.toString());

    dropValueLoading=true;
        if(result!='{"content":[]}'){
          var jsonData=jsonDecode(result);
          dropdownList=jsonData['content'];
          var product=dropdownList[0]['dropvalue'];
          var ticketstatus=dropdownList[1]['dropvalue'];
          var source=dropdownList[5]['dropvalue'];
          var priority=dropdownList[3]['dropvalue'];
          var industrytype=dropdownList[4]['dropvalue'];

          log("new droppsss "+dropdownList.toString());

          productList.addAll(product);
          statusList.addAll(ticketstatus);
          industryList.addAll(industrytype);
          leadQualityList.addAll(priority);
          mySourceList.addAll(source);

        //  assignList.addAll(assignAgent);
        }else{
          log('empty');
        }
        setState(() {});
      }
      else{
        log("20000 "+dropdownList.toString());

    if(response.reasonPhrase.toString()=='Unauthorized'){
          MySessions.sessionExpire(context);
        }else{
          errorDropValue="Error";
          noConnection();
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network Error')));
          log(response.reasonPhrase.toString());
          setState(() {
          });
        }
      }
    }catch(e){
      log("ssss "+dropdownList.toString());

      if(e.toString()=='Unauthorized'){
        MySessions.sessionExpire(context);
      }else{
        log(e.toString());
        errorDropValue="Error";
        noConnection();
        //  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network Error')));
        setState(() {
        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void noConnection(){
    showDialog(barrierDismissible: false,
        context: context, builder: (BuildContext ctx){
          return AlertDialog(
            title: const Text('Failed to load List'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: const Text('Ok')),
              TextButton(onPressed: (){
                Navigator.pop(context);
                getDropdownValue();
              }, child: const Text('try again')),
            ],
          );
        });
  }

  clearData(){
    firstName.clear();
    emailId.clear();
    walkIn.clear();
    website.clear();
    contact.clear();
    alternateNo.clear();
    organization.clear();
    state.clear();
    message.clear();
    description.clear();
    address.clear();
  }

@override
  void initState() {
    super.initState();
    // mySourceList.addAll(widget.sourceList);
     log("new ${widget.dropdownList}");
    getSharedPreference();
  }


  Widget _mandatoryField(){
    return const Text(' *',style: TextStyle(color: Colors.red,fontSize:22 ),);
  }

  Widget _widgetTextField({required TextEditingController controller,required String hint}){
    return SizedBox(width: MediaQuery.of(context).size.width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  Widget _widgetTexNumbers({required TextEditingController controller,required String hint}){
    return SizedBox(width: MediaQuery.of(context).size.width,
      child: TextField(
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  // showNotification(int id,String title,String msg) async {
  //   AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
  //       "psl_notifications",
  //       "high Notifications",
  //       priority: Priority.defaultPriority,
  //       playSound: true,
  //       importance: Importance.defaultImportance,
  //       //icon: "assets/images/psl.jpg",
  //       color: Colors.red
  //   );
  //
  //   DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //
  //   NotificationDetails notificationDetails = NotificationDetails(
  //       android: androidDetails,
  //       iOS: iosDetails
  //   );
  //   await notificationsPlugin.show(id, title, msg, notificationDetails);
  // }

  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width<=480?105.0:150.0; // for tab
    var textSize=16.0;
    return Scaffold(
      appBar: AppBar( foregroundColor: mColor,
        title: const Text("Add Leads",),
        centerTitle: true,
        actions: [
          SizedBox(width: 80,child: logo),
          const SizedBox(width: 10,)
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: MediaQuery.of(context).size.height*0.96,
            margin: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        width: width,
                      child:   Text("Walk-In Name",style: TextStyle(fontSize: textSize),),
                      ),
                      Expanded(child: _widgetTextField(controller: walkIn, hint: 'Enter Walk-In Name')),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Row(children: [
                    SizedBox(width: width,
                        child: Text("First Name",style: TextStyle(fontSize: textSize),)),Expanded(child: _widgetTextField(controller: firstName, hint: 'Enter First Name'))],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Email ID",style: TextStyle(fontSize: textSize),)),
                    Expanded(child: _widgetTextField(
                        controller: emailId, hint: 'Enter E-Mail'))],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Row(
                        children: [
                          Text("Contact No.",style: TextStyle(fontSize: textSize),),
                      _mandatoryField(),
                        ],
                      )),
                    Expanded(child: _widgetTexNumbers(controller: contact, hint: 'Enter Contact Number'))],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Alternate No.",style: TextStyle(fontSize: textSize),)),
                    Expanded(child: _widgetTexNumbers(controller: alternateNo, hint: 'Enter Alternate Number'))],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Row(
                        children: [
                          Text("Product",style: TextStyle(fontSize: textSize),),
                      _mandatoryField(),
                        ],
                      )),
                    Expanded(
                      child: Container(height: 60,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                      padding: const EdgeInsets.only(left: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint:dropValueLoading? Text(
                            ' --Select-- ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                            ),
                          ):Text(errorDropValue),
                          items: productList
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                              .toList(),
                          value: productValue,
                          onChanged: (value) {
                            setState(() {
                              productValue = value as String;
                            });
                          },
                        ),
                      ),
                  ),
                    ),],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Organization Name",style: TextStyle(fontSize: textSize),)),
                    Expanded(child: _widgetTextField(controller: organization, hint: 'Enter Organization Name'))],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Address",style: TextStyle(fontSize: textSize),)),
                    Expanded(child:
                    TextField(controller: address,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      minLines: 3,
                      decoration: InputDecoration(hintText: "Enter Address",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    )
                    )],),
                  const SizedBox(height: 15,),
                  Row(children: [
                    SizedBox(width: width,
                      child: Text("Lead Quality",style: TextStyle(fontSize: textSize),)),
                    Expanded(
                      child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                      height: 60,
                      padding: const EdgeInsets.only(left: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint:dropValueLoading? Text(
                            ' --Select-- ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                            ),
                          ):Text(errorDropValue),
                          items: leadQualityList
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                              .toList(),
                          value: leadQualityValue,
                          onChanged: (value) {
                            setState(() {
                              leadQualityValue = value as String;
                            });
                          },

                        ),
                      ),
                  ),
                    ),],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("State",style: TextStyle(fontSize: textSize),)),
                    Expanded(child: _widgetTextField(controller: state, hint: 'Enter State'))],),
                  const SizedBox(height: 15,),
                  Row(children: [
                    SizedBox(width: width,
                      child: Text("Lead Status",style: TextStyle(fontSize: textSize),)),
                    Expanded(
                      child: Container(height: 60,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                       padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint:dropValueLoading? Text(
                            ' --Select-- ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                            ),
                          ):const Text('Loading...'),
                          items: statusList
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                              .toList(),
                          value: statusSellValue,
                          onChanged: (value) {
                            setState(() {
                              statusSellValue = value as String;
                            });
                          },

                        ),
                      ),
                  ),
                    ),],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Row(
                        children: [
                          Text("Source",style: TextStyle(fontSize: textSize),),
                      _mandatoryField(),
                        ],
                      )),
                    Expanded(
                      child: Container(height: 60,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                  //  width: 2,
                        padding: const EdgeInsets.only(left: 10),

                        child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint:dropValueLoading? Text(
                            ' --Select-- ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                            ),
                          ):const Text('Loading'),
                          items: mySourceList
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                              .toList(),
                          value: sourceValue,
                          onChanged: (value) {
                            setState(() {
                              sourceValue = value as String;
                            });
                          },
                        ),
                      ),
                  ),
                    ),],),
                  const SizedBox(height: 15,),

                  Row(
                    children: [
                      SizedBox(width: width,
                          child: const Text('Assigned\n Agent Name')),
                      Expanded(
                        child: Container(height: 60,alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(color: Colors.black12,
                              borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                          padding: const EdgeInsets.only(left: 10),
                          child: Text('$assignedAgentName'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Website",style: TextStyle(fontSize: textSize),)),
                    Expanded(child: _widgetTextField(controller: website, hint: 'Enter Website'))],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Industry Type",style: TextStyle(fontSize: textSize),)),
                    Expanded(
                      child:
                      Container(
                        height: 60,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                           padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          menuMaxHeight: 300,
                          hint:dropValueLoading? Text(
                            ' --Select-- ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme
                                  .of(context)
                                  .hintColor,
                            ),
                          ):Text(errorDropValue),
                          items: industryList
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                              .toList(),
                          value: industryTypeValue,
                          onChanged: (value) {
                            setState(() {
                              industryTypeValue = value as String;
                            });
                          },
                        ),
                      ),
                  ),
                    ),],),
                  const SizedBox(height: 15,),
                  Row(children: [SizedBox(width: width,
                      child: Text("Description",style: TextStyle(fontSize: textSize),)),
                    Expanded(child: _widgetTextField(controller: description, hint: 'Enter Description'))],),

                  const SizedBox(height: 15,),
                  Row(
                    children: [
                      SizedBox(width: width,
                          child: Text("Message",style: TextStyle(fontSize: textSize),)),
                      Expanded(child: _widgetTextField(controller: message, hint: 'Enter Message')),
                    ],), const SizedBox(height: 20,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Container(color: mColor,height: 50,width: 250,
                        child: TextButton(onPressed: (){
                          addLeads();
                        }, child: const Text("Submit",style: TextStyle(color: Colors.white,fontSize: 20),))
                    ),
                  //  Expanded(child: Container()),
                  //   Container(height: 50,
                  //       child: ElevatedButton(onPressed: (){
                  //         showDialogs();
                  //       }, child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 20),))),
                  ],)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}