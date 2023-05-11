import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gm/SessionPage/MySession.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import '../ApiService/BaseUrl.dart';
import '../HomePage.dart';
import '../Models/LeadsDetailsModels.dart';
import 'CreateTaskPage.dart';


class EditLeads extends StatefulWidget {
  final sourceLead;
  final leadModel;
  final dropList;
  const EditLeads({Key? key,required this.sourceLead,required this.leadModel,required this.dropList}) : super(key: key);

  @override
  State<EditLeads> createState() => _EditLeadsState();
}

class _EditLeadsState extends State<EditLeads> {

  TextEditingController updateAlternate =TextEditingController();
  TextEditingController updateAddress =TextEditingController();
  TextEditingController updateState =TextEditingController();
  TextEditingController updateWebsite =TextEditingController();
  //extEditingController updateIndustry =TextEditingController();
  //TextEditingController updateAgent =TextEditingController();
  //TextEditingController updateLeadStatus =TextEditingController();
 // TextEditingController updateReason =TextEditingController();
  //TextEditingController updateQuality =TextEditingController();
  //TextEditingController updateProduct =TextEditingController();
  TextEditingController updateDesc =TextEditingController();
  TextEditingController updateMessage =TextEditingController();
  //TextEditingController updateSourceLeadName =TextEditingController();

  var jsonData;
  late LeadDetailsModel modelData;
  late SharedPreferences sharedPreferences;
  String? getCookies;
  String? msg;
  String statusHint='';
  var title='';
  bool isDialog=false;
  bool isLoading=false;
  bool dropValueLoading=false;
  bool statusLoading=true;
  bool statusNull=false;
  bool checkChanges=false;

  var assignedAgentName;
  String? name;
  String? email;
  String? number;
  String? sourceLead;
  String? company;

  var leadQualityList=[];
  var leadQualityValue;
  // var product List=[];
  // var product Value;
  var statusReasonList=[];
  var statusValue;
  var leadStatusList=[];
  var leadStatusValue;
  var industryNameList=[];
  var industryValue;
  bool isErrorUpdate=false;

  Future<void> getSharedPreference()async{
    sharedPreferences=await SharedPreferences.getInstance();
    getCookies= sharedPreferences.getString('cookie');
    assignedAgentName=sharedPreferences.getString('agentName');
    log(assignedAgentName);
    print("kkkkk $getCookies");
    dropValueLoading=true;
    getDropValue();
  }

  getDropValue(){
    dropValueLoading=true;

    leadQualityList.clear();
    industryNameList.clear();
   // productList.clear();

    if(widget.dropList.toString().isNotEmpty){
      try{
        log('errrrrrorrrrrr ${widget.dropList[0]['dropvalue']}');
        var product=widget.dropList[0]['dropvalue'];
        var ticketstatus=widget.dropList[1]['dropvalue'];
        var priority=widget.dropList[3]['dropvalue'];
        var industrytype=widget.dropList[4]['dropvalue'];

       // productList.addAll(product);
        leadStatusList.addAll(ticketstatus);
        industryNameList.addAll(industrytype);
        leadQualityList.addAll(priority);

        setState(() {});
      }catch(e){
        log(e.toString());
        getDropdownValue();
      }
    }else{
      log('error lod list');
      getDropdownValue();
    }
  }

  Future<void> getDropdownValue()async{
    dropValueLoading=false;

    log('message');
    try{
      var headers = {
        'cookie':'$getCookies'
      };
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/dropdown'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {

        var result=await response.stream.bytesToString();
        dropValueLoading=true;
        log(result.toString());

        if(result.toString()!='{"content":[]}'){

          var jsonData=jsonDecode(result);
          var dropdownList=jsonData['content'];

          log('ddddd $result');

          var product=dropdownList[0]['dropvalue'];
          var ticketstatus=dropdownList[1]['dropvalue'];
         // var assignAgent=dropdownList[2]['dropvalue'];
          var priority=dropdownList[3]['dropvalue'];
          var industrytype=dropdownList[4]['dropvalue'];

         // productList.addAll(product);
          leadStatusList.addAll(ticketstatus);
          industryNameList.addAll(industrytype);
          leadQualityList.addAll(priority);
        }
        setState(() {});
      }
      else {
        log('dddddddddddssss');
        log(response.reasonPhrase.toString());
        if(response.reasonPhrase=='Unauthorized'){
          MySessions.sessionExpire(context);
        }
      }
    }catch(e){
      log(e.toString());
    }
  }

  void showDialogs(){
    showDialog(barrierDismissible: false,
        context: context, builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async =>isDialog?true:false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
             // title:isDialog?null:Text(title),
              actions: [
                isDialog?Text(msg!): Container(alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10,bottom: 10,left: 20.0),
                  child:Row(
                  //  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 25,height: 25,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2,color: mColor,))),SizedBox(width: 10,),Text('Updating Data...'),
                    ],
                  ),
                ),
                isDialog? TextButton(onPressed: (){
                  if(isErrorUpdate){
                    Navigator.pop(context);
                  }else{
                    if(leadStatusValue.toString()=='${modelData.leadStatus}'){
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LeadCounterPage()), (route) => false);

//                  Navigator.of(context)..pop()..pop()..pop()..pop();
                    }else{
                         Navigator.of(context)..pop()..pop();
                    //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LeadCounterPage()), (route) => false);
                      //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LeadsDetails()));
                    }
                  }
                }, child: const Text('OK')):Container(),
              ],
            ),
          );
        });
  }

  void closeDialog(){
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
  }
bool isCheckData=false;
  setDataEditText(){
    try{
      Map<String , dynamic> jsonMap=jsonDecode(widget.leadModel);
      modelData=LeadDetailsModel.fromJson(jsonMap);

      name=modelData.name.toString();
      email=modelData.email.toString();
      number=modelData.contactNo.toString();
      updateAlternate.text=modelData.alternateNo.toString();
      updateAddress.text=modelData.address.toString();
      updateState.text=modelData.state.toString();
      sourceLead=modelData.leadSource.toString();
      company=modelData.companyName.toString();
      updateWebsite.text=modelData.website.toString();
      // updateIndustry.text=modelData.industryType.toString();
      // updateAgent.text=modelData.assignedAgent.toString();
      // updateLeadStatus.text=modelData.leadStatus.toString();
      // updateReason.text=modelData.statusReason.toString();
      // updateQuality.text=modelData.leadquality.toString();
      // updateProduct.text=modelData.product.toString();
      updateDesc.text=modelData.description.toString();
      updateMessage.text=modelData.message.toString();

      isCheckData=true;

    }catch(e){
      log(e.toString());
    }
  }

  Future<void> checkFillUpField()async {
    log(modelData.leadStatus.toString());
    log(modelData.leadSource.toString());
    log(modelData.leadId.toString());
    // log("${leadStatusValue.toString()=='null'?modelData.leadStatus.toString():leadStatusValue.toString()}");

    if (leadStatusValue == 'open' || leadStatusValue == 'deal won') {
      if(updateDesc.text.trim().isEmpty){
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Enter Description')));
      }
      else{
updateLeads();
      }

      log('ffffff');
    }else if(leadStatusValue=='followup' || leadStatusValue=='close' || leadStatusValue=='working'){
      if(statusValue==null){
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Select Status Reason')));
      }else if(updateDesc.text.trim().isEmpty){
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Enter Description')));
      }else{
updateLeads();
      }
    }
    else {
updateLeads();
  }
  }
  Future<void> updateLeads()async {
    try {
      isDialog = false;
    //  title = "Please Wait...";
      showDialogs();
      var headers = {
        'Content-Type': 'application/json',
        'cookie': '$getCookies'
      };
      var request = http.Request(
          'PUT', Uri.parse('${BaseUrl.apiBaseUrl}/addnewLead'));
      request.body = json.encode({
        "leadId": modelData.leadId.toString(),
        "name": modelData.name.toString(),
        "email": modelData.email.toString(),
        "contactNo": modelData.contactNo.toString(),
        "alternateNo": updateAlternate.text.trim().toString(),
        "address": updateAddress.text.trim().toString(),
        "state": updateState.text.trim().toString(),
        "leadSource": modelData.leadSource.toString(),
        "companyName": modelData.companyName.toString(),
        "leadquality": leadQualityValue.toString() == 'null' ? modelData
            .leadquality.toString() : leadQualityValue.toString(),
        "website": updateWebsite.text.trim().toString(),
        "industryType": "${industryValue.toString() == 'null' ? modelData
            .industryType : industryValue.toString()}",
        "leadStatus": leadStatusValue.toString() == 'null' ? modelData
            .leadStatus.toString() : leadStatusValue.toString(),
        "statusReason": statusValue.toString() == 'null' ? modelData
            .statusReason.toString() : statusValue.toString(),
        "assignedAgent": assignedAgentName.toString(),
        "timestamp": DateTime.now().toString(),
        "product": modelData.product.toString(),
        "description": updateDesc.text.trim().toString()
        // "sourcename": 'null',
        // "message": "",
        // "createdBy": ""
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        isDialog = true;
        closeDialog();
        isErrorUpdate=false;
        msg = "Records Updated Successfully";
        if (response.reasonPhrase.toString() == 'Unauthorized') {
          MySessions.sessionExpire(context);
        } else {
          showDialogs();
          print(res);
        }
      }
      else {
        isDialog = true;
        closeDialog();
        isErrorUpdate=true;
        msg = "Failed to Updated";
        showDialogs();
        print(response.reasonPhrase);
      }
    }on TimeoutException catch (_) {
      // isLoading=true;
       msg="Your connection has Timed Out";
      isDialog = true;
      isErrorUpdate=true;
      closeDialog();
      showDialogs();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your connection has timed out')));
      //  closeDialog();
      print("Connection timed out");
    }on SocketException catch (e) {
      log(e.toString());
      if(e.toString()=='Connection timed out'){
        msg="Connection timed out";
      }else{
        msg="You are not connected to internet";
      }
      log('expire');
      isDialog = true;
      isErrorUpdate=true;
      closeDialog();
      showDialogs();

      // closeDialog();
      print("You are not connected to internet");
    }
  }


  void checkStatus(String mStatus){
    if(mStatus=='working'){
      log('working');
      getStatusReason(mStatus);
    }else if(mStatus=='close'){
      log('close');
      getStatusReason(mStatus);
    }else if(mStatus=='followup'){
      log('followup');
    getStatusReason(mStatus);
    }
  }

  void getStatusReason(String mStatus)async{
   // statusReasonList.clear();
    var headers = {
      'Cookie': '$getCookies'
    };
    try{
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/statusReason?status=$mStatus'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        statusLoading=false;
        statusNull=true;
        statusHint='Select Status Reason';
        var data=await response.stream.bytesToString();
        var jsonData=jsonDecode(data);
        statusReasonList.addAll(jsonData);
        setState(() {});
      }
      else {
        statusHint='Error';
        statusNull=true;
        setState(() {});
        log(response.reasonPhrase.toString());
      }
    }catch(e){
      statusHint='Error';
      statusNull=true;
      setState(() {});
    }
  }



  @override
  void initState() {
    super.initState();
    log('drop list ${widget.dropList}');
    log('model ${widget.leadModel}');
    setDataEditText();
    getSharedPreference();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget editText(var controller,var hint){
    return TextField(controller: controller,onChanged: (v){checkChanges=true;},
       decoration: InputDecoration(labelText: hint,
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
       ),
    );
  }

  Widget editNumber(var controller,var hint){
    return TextField(controller: controller,onChanged: (v){checkChanges=true;},
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
      ),
    );
  }

  Widget readOnlyEditText(var controller, var hint){
    return Container(width: 700,color: Colors.black12,
      child: TextField(readOnly: true,controller: controller,
        decoration: InputDecoration(labelText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width*0.87;
    var width1=86.0;
    return GestureDetector(onTap: (){
      FocusScope.of(context).unfocus();
    },
      child: Scaffold(
        appBar: AppBar(foregroundColor: mColor,
          title: const Text('Edit Lead'),centerTitle: true,
          actions: [
            checkChanges?IconButton(onPressed: (){
            checkFillUpField();
            }, icon: Icon(Icons.check,color: mColor,)):SizedBox(width: 80,child: logo),
              // SizedBox(width: 80,child: logo),
               const SizedBox(width: 10,),
          ],),
        body:isCheckData?SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Column(
              children:<Widget> [
                Container(
                    margin: const EdgeInsets.all(8.0),
                     padding: const EdgeInsets.only(bottom: 20,),
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Container(alignment: Alignment.center,
                            //     height: 60,
                            //     width: 300,
                            //     color: Colors.orange.shade400,
                            //     child: Text("Lead Id : ${modelData.leadId}",style: const TextStyle(fontSize: 22),)),
                            // const SizedBox(height: 20,),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     SizedBox(width: width1,
                            //         child: Text('${widget.sourceLead} Name')),
                            //     Expanded(child: editText(updateSourceLeadName,"")),
                            //   ],
                            // ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Name')),
                                Expanded(
                                  child: Container(height: 60,alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text('$name'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('E-Mail')),

                                Expanded(
                                  child: Container(height: 60,alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(email.toString()==''?"N/A":email.toString()),
                                  ),
                                ),
                              //  Expanded(child: readOnlyEditText(updateEmail,"E-mail")),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Contact No.')),
                                Expanded(
                                  child: Container(height: 60,alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(number.toString()==''?"N/A":number.toString()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Alternate No.')),
                                Expanded(child: editNumber(updateAlternate,"Alternate Number")),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width:width1,child: const Text('Address')),
                                Expanded(child: editText(updateAddress,"Address")),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('State')),
                                Expanded(child: editText(updateState,"State")),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Source Lead')),
                                Expanded(
                                  child: Container(height: 60,alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text('$sourceLead'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(
                                    width: width1,
                                    child: const Text('Company')),
                                Expanded(
                                  child: Container(height: 60,alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text('$company'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Website')),
                                Expanded(child: editText(updateWebsite,"Website")),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Industry\nType')),
                                Expanded(
                                  child: Container(height: 60,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        menuMaxHeight: 300,
                                        hint:dropValueLoading? Text(
                                          modelData.industryType.toString()==''?"N/A":modelData.industryType.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme
                                                .of(context)
                                                .hintColor,
                                          ),
                                        ):const Text('Loading'),
                                        items: industryNameList
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
                                        value: industryValue,
                                        onChanged: (value) {
                                          checkChanges=true;
                                          setState(() {
                                            industryValue = value as String;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Assigned\nAgent')),
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
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Lead Status')),
                                Expanded(
                                  child: Container(height: 60,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        hint:dropValueLoading? Text(
                                          modelData.leadStatus.toString()==''?"N/A":modelData.leadStatus.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme
                                                .of(context)
                                                .hintColor,
                                          ),
                                        ):const Text('Loading'),
                                        items: leadStatusList
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
                                        value: leadStatusValue,
                                        onChanged: (value) {
                                          statusReasonList.clear();
                                          statusValue=null;
                                          checkChanges=true;
                                          if(value.toString()=='open' || value.toString()=='deal won'){
                                            statusNull=true;
                                            statusHint="N/A";
                                            log('llllllllllllll');
                                            setState(() {
                                              leadStatusValue = value as String;
                                            });
                                          }else{
                                            statusNull=false;
                                            checkStatus(value.toString());
                                            setState(() {
                                              leadStatusValue = value as String;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Status\nreason')),
                                Expanded(
                                  child: Container(height: 60,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        hint:statusLoading? Text(
                                          modelData.statusReason.toString()==''?"N/A":modelData.statusReason.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme
                                                .of(context)
                                                .hintColor,
                                          ),):statusReasonList.isNotEmpty?const Text('Select Status Reason',):statusNull?Text(statusHint,style: const TextStyle(color: Colors.black26),):const Text('Loading...'),
                                        items: statusReasonList
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
                                        value: statusValue,
                                        onChanged: (value) {
                                          checkChanges=true;
                                          if(value.toString()=='Demo / Meeting '){
                                            statusValue=null;
                                            showAddEventWidgets(context).then((val){
                                              log("show $val");
                                            });
                                           // showAddEventWidget();
                                          }else{
                                            setState(() {
                                              log(value.toString());
                                              statusValue = value as String;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Lead\nQuality')),
                                Expanded(
                                  child: Container(height: 60,width: width,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        hint:dropValueLoading? Text(
                                          modelData.leadquality.toString()==''?"N/A":modelData.leadquality.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme
                                                .of(context)
                                                .hintColor,
                                          ),
                                        ):const Text('Loading'),
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
                                            checkChanges=true;
                                            leadQualityValue = value as String;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ), //  modelData.product.toString()==''?"N/A":modelData.product.toString(),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Product')),
                                Expanded(
                                  child: Container(height: 60,alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(modelData.product.toString()==''?"N/A":modelData.product.toString(),),
                                  ),
                                ),
                              ],
                            ),
                            // Row(
                            //   children: [
                            //     SizedBox(width: width1,
                            //         child: const Text('Product')),
                            //     Expanded(
                            //       child: Container(height: 60,width: width,
                            //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black38)),
                            //         padding: const EdgeInsets.only(left: 10),
                            //         child: DropdownButtonHideUnderline(
                            //           child: DropdownButton(
                            //             hint:dropValueLoading? Text(
                            //
                            //               style: TextStyle(
                            //                 fontSize: 14,
                            //                 color: Theme
                            //                     .of(context)
                            //                     .hintColor,
                            //               ),
                            //             ):const Text('Loading'),
                            //             items: []
                            //                 .map((item) =>
                            //                 DropdownMenuItem<String>(
                            //                   value: item,
                            //                   child: Text(
                            //                     item,
                            //                     style: const TextStyle(
                            //                       fontSize: 14,
                            //                     ),
                            //                   ),
                            //                 ))
                            //                 .toList(),
                            //             value: productValue,
                            //             onChanged: (value) {
                            //               setState(() {
                            //                 checkChanges=true;
                            //                 productValue = value as String;
                            //               });
                            //             },
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Description')),
                                Expanded(child: editText(updateDesc,"Description")),
                              ],
                            ),const SizedBox(height: 15,),

                            leadStatusValue=='close'? Row(
                              children: [
                                SizedBox(width: width1,
                                    child: const Text('Closed Comment')),
                                Expanded(child: TextField(maxLines: 2,
                                  decoration: InputDecoration(hintText: "Enter Your Comment",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
                                  ),
                                )
                                ),
                              ],
                            ):Container(),
                          ],
                        ))
                ),
              ],
            ),
          ),
        ):const Center(child: Text('Edit Not Available'),)
      ),
    );
  }
}
