import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gm/Screens/CreateTaskPage.dart';
import 'package:gm/SessionPage/MySession.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ApiService/BaseUrl.dart';
import '../EmailPage.dart';
import '../HomePage.dart';
import '../Models/LeadsDetailsModels.dart';
import '../SmsPage.dart';
import 'EditLeads.dart';
import 'ShowAllComments.dart';
import 'ViewActivityPage.dart';

class LeadsDetails extends StatefulWidget {
  final nullSouceName;
  final leadId;
  final status;
  final sourceLead;
  const LeadsDetails({Key? key, this.leadId, this.status, this.sourceLead, this.nullSouceName}) : super(key: key);

  @override
  State<LeadsDetails> createState() => _LeadsDetailsState();
}

class _LeadsDetailsState extends State<LeadsDetails> {

  TextEditingController walkIn = TextEditingController();
  TextEditingController commentController = TextEditingController();
  late SharedPreferences sharedPreferences;
  //fdfdfdfd
  String? getCookies;
  var responseData;
  bool isLoading=false;
  bool loadError=true;
  String? assignedAgentName;
  late LeadDetailsModel leadDetailModel;
  int commentLength=0;
  int activityLength=0;
  var nullJsonDataList;

  // var agentSize;
  // var agentPage;
  var getDropdownList=[];

  var mySourceList=[];
  bool dropValueLoading=false;
  var sourceValue;
  //var fileName;
  var file;

  var showMsg=TextOverflow.ellipsis;
  var ind=0;

  String commentUrl='';

  List colors=[Colors.orange,Colors.blueGrey,Colors.blue,Colors.red,Colors.green,Colors.greenAccent,Colors.indigo,Colors.purple,Colors.cyan.shade300,Colors.green.shade400,Colors.purple.shade400,Colors.lightBlue.shade300,Colors.deepPurpleAccent.shade400,Colors.purple.shade300];
  var msg="Record Save Successfully";

  Future<void> getSharedPreference()async{
    sharedPreferences=await SharedPreferences.getInstance();
    getCookies= sharedPreferences.getString('cookie');
     assignedAgentName=sharedPreferences.getString('agentName');
    // agentPage= sharedPreferences.getString('pageNumber');
    // agentSize= sharedPreferences.getString('size');
    //print("kkkkk $getCookies");
    getLeadDetails();
  }

  Future<void> commentPost()async{
    var res=await http.post(Uri.parse(commentUrl));
    if(res.statusCode==200){

    }
  }


  Future<void> getDropdownValue()async{
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

        if(result.toString()!='{"content":[]}'){
          var jsonData=jsonDecode(result);
           getDropdownList.addAll(jsonData['content']);
        }
      }
      else {
        log('dddddddddddssss');
      }
    }catch(e){
      log(e.toString());
    }
  }

  Future<void> getLeadDetails()async{
      isLoading=false;
    log('kjgjghjghj ${widget.nullSouceName}');
    String url;
    try{
      if(widget.nullSouceName=='null'){
         url = '${BaseUrl.apiBaseUrl}/leadView?sourceLead=null&status=open&leadId=${widget.leadId}';
      }else{
        log('message');
         url='${BaseUrl.apiBaseUrl}/leadView?sourceLead=${widget.sourceLead}&status=${widget.status}&leadId=${widget.leadId}';

         log(url.toString());
      }
      var headers = {
        'Content-Type': 'application/json',
        'Cookie':'$getCookies',
        // 'Cache-Control':'no-cache'
      };

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        responseData= await response.stream.bytesToString();
       // log(responseData.toString());
        Map<String , dynamic> jsonMap=jsonDecode(responseData);
        leadDetailModel=LeadDetailsModel.fromJson(jsonMap);
        log("comment ${leadDetailModel.comment}");

        log("ffffffffffff"+responseData.toString());

        //for activity

        if(leadDetailModel.eventDetails!=null){
          try{
            List<dynamic> activitylenh=leadDetailModel.eventDetails;
            commentLength=activitylenh.length;
            log(leadDetailModel.eventDetails.toString());
          }catch(e){
            print(leadDetailModel.eventDetails);
            print('event dETAILS  $e');
          }
        }

        // for comment

        if(leadDetailModel.comment!=null){
          try{
            List<dynamic> commentLenh=leadDetailModel.comment;
            commentLength=commentLenh.length;
            log(leadDetailModel.comment.toString());
          }catch(e){
            print(leadDetailModel.comment);
            print('fgfgdf  $e');
          }
          log('kkkkkkk');
        }
        setState(() {
          isLoading=true;
        });
      }
      else {
        print("uuuuuuuu "+response.reasonPhrase.toString());
        if(response.reasonPhrase=='Unauthorized'){
          MySessions.sessionExpire(context);
          setState(() {
            isLoading=false;
            loadError=false;
          });
        }
      }
    }catch(e){
      log("ram go to market$e");
      setState(() {
        isLoading=false;
        loadError=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to Load Data')));
    }
    getDropdownValue();
  }

  void showSuccessDialog(){
    showDialog(context: context, builder: (BuildContext ctx){
      return AlertDialog(
        title: Text(msg.toString()),
        actions: [TextButton(onPressed: (){
          Navigator.pop(context);
          getLeadDetails();
        }, child: const Text('Ok'))],
      );
    });
  }

  void addCommentDialog(){
    if(commentController.text.isNotEmpty){
      showDialog(barrierDismissible: false,
          context: context, builder: (BuildContext ctx){
            return WillPopScope(
              onWillPop: ()async=>false,
              child: AlertDialog(
                shape: const StadiumBorder(
                  side: BorderSide(
                    color: Colors.orange,
                    width: 1.0,
                  ),
                ), content: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2,color: mColor,)),const SizedBox(width: 8,),
                    const Text("Uploading Comment..."),
                  ],
                ),
              ),
              ),
            );
          });

      addComments();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.orange.shade400,content: const Text('Enter Comment First')));
    }
  }

  void addComments()async{

    String fileStatus;

    if(file.toString()=='null'){
      fileStatus='no';
      log('nooooooo');
    }else{
      log('yesssssss');
      fileStatus='yes';
    }
    try{
      var headers = {
        'Content-Type': 'application/json',
        'Cookie': '$getCookies'
      };
      var request = http.Request('POST', Uri.parse('${BaseUrl.apiBaseUrl}/addComments'));
      request.body = json.encode({
        "leadId": widget.leadId.toString(),
        "Agent": assignedAgentName,
        "Timestamp": "${DateTime.now()}",
        "Comment": commentController.text.toString(),
        "filestring": "",
        "fileName": "",
        "fileExtension": "",
        "fileStatus": fileStatus.toString()
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        commentController.clear();
        file='null';
        msg="Comment Uploaded";
        closeDialog();
        showSuccessDialog();
        print(await response.stream.bytesToString());
    }
    else {
    msg="Failed to Uploaded";
    closeDialog();
    print(response.reasonPhrase);
    }
    }on TimeoutException catch (_) {
    msg="Your connection has timed out";
    closeDialog();
    print("Your connection has timed out");
    }on SocketException catch (_) {
    msg="You are not connected to internet";
    closeDialog();
    print("You are not connected to internet");
    }
  }

  void closeDialog(){
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    log("file $file");
    getSharedPreference();
    print(widget.status);
    print("id "+widget.leadId);
  }

  Future<void> _refresh() async {
    getLeadDetails();
  }

  @override
  void dispose() {
    //_controller.close();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }


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
             closeDialog();
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

  Widget textField({required TextEditingController controller}){
    return Container(
        height: 40,
        width: 250,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.orangeAccent,width: 3)
        ),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder( borderSide: BorderSide.none)),
        )
    );
  }

  _launchWhatsapp(var number) async {
    var iosUrl = "https://wa.me/+91$number?text=${Uri.parse('Hi,')}";

    var whatsappUrl =
        "whatsapp://send?phone=+91$number""&text=${Uri.encodeComponent('hello')}";
    try {
      if(Platform.isIOS){
        await launchUrl(Uri.parse(iosUrl),
            mode: LaunchMode.externalApplication);
      }else{
        if (await canLaunch(whatsappUrl)) {
          await launch(whatsappUrl);
        }else{
          try{
            launchUrl(Uri.parse('https://wa.me/+91$number?text=Hi'),
                mode: LaunchMode.externalApplication);
          }catch(e){
           // showScaffold("Whatsapp not installed. $number'");

ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Whatsapp not installed. $number'),),);
          }
        }
      }
    } catch (e) {
      try{
        log('message');
        launchUrl(Uri.parse('https://wa.me/+91$number?text=Hi'),
            mode: LaunchMode.externalApplication);
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Whatsapp not installed. $number'),),);
      }
    }

  }

  _launchPhone(var number)async{
    var url = "tel:+91$number";
    if(Platform.isAndroid){
      log('dfd');
      if (await canLaunch(url)) {
        await launch(url);
      } else {
      //  showScaffold("Unable to call $url");

ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $url")));
      }
    }else{
      if (await canLaunch(url)) {
        await launch(url);
      }else{
       // showScaffold("Unable to call $url");
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $url")));

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var dividerColor=Colors.black87;
    var fontSize=14.0;
    var width=85.0;
    var overflow= MediaQuery.of(context).size.width*0.55;
    return Scaffold(
        appBar: AppBar(
          foregroundColor:mColor,
          title: const Text('Lead Details',),centerTitle: true,
          actions: [
           SizedBox(width: 80,child: logo),
            const SizedBox(width: 10,)
          ],
        ),
        body:SafeArea(
          child: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: LiquidPullToRefresh(
              showChildOpacityTransition: false,
                backgroundColor: Colors.white,
                color: Colors.orange.shade300,
              onRefresh: () {
               return _refresh();
              },
                  child: (isLoading)? SingleChildScrollView(
                    primary: true,
                  child: Column(
                children: [

                  const SizedBox(height: 10,),
                  // show data
                  Container(
                      margin: const EdgeInsets.only(left: 8,bottom: 10,right: 8),
                       padding: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4,left: 10,right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(height: 36,
                                    padding: const EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(boxShadow: const [
                                      BoxShadow(
                                          color: Colors.white30,blurRadius: 2,spreadRadius: 4,offset: Offset(0,1)
                                      )
                                    ],
                                        border: Border.all(color: Colors.black12),borderRadius: BorderRadius.circular(10.0)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                          //  log(dataList[index]['contact']);

                                            _launchPhone(leadDetailModel.contactNo.toString());
                                          }, icon:  Icon(Icons.call_outlined,color: mColor,size: 20,),),const SizedBox(width: 10,),
                                        IconButton(icon: Icon(Icons.sms,color: mColor,size: 20,),
                                          onPressed: ()async {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> SendSms(phoneNumber: leadDetailModel.contactNo.toString(),)));
//_launchSms(dataList[index]['contact']);
                                          },
                                        ),const SizedBox(width: 10,),
                                        IconButton(icon:  Icon(Icons.email,color: mColor,size: 20,),
                                          onPressed: ()async {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const SendEmail()));
//_launchEmail(dataList[index]['email']);
                                          },
                                        ),const SizedBox(width: 10,),
                                        GestureDetector(onTap:(){
                                          log('whatsapp');
                                          _launchWhatsapp(leadDetailModel.contactNo.toString());
                                         // log(dataList[index]['contact'].toString());
                                        },
                                            onLongPress: (){
                                           //   log(dataList[index]['contact'].toString());
                                            },
                                            child: Image.asset('assets/whatsapp240.png',height: 25,width: 25,)),
// SizedBox(width: 1,),
                                      ],
                                    ),
                                  ),
                                ),
                               // const Text("Key Fields",style: TextStyle(fontSize: 24,color: Colors.black87),),
                                IconButton(onPressed: (){
                                  if(isLoading){
                                    Navigator.push(context, CupertinoPageRoute(fullscreenDialog: true,
                                        builder: (context)=>EditLeads(sourceLead: widget.sourceLead, leadModel: responseData, dropList: getDropdownList,)));
                                  }
                                }, icon: Icon(Icons.edit,size:25,color: mColor,)),
                              ],
                            ),
                            Divider(thickness: 1,color: mColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Source Name",style: TextStyle(fontSize: fontSize),)),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child: Text("${widget.sourceLead}",style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,)),
                              ],
                            ), Divider(color:dividerColor),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Name",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child: Text(leadDetailModel.name.toString(),style: const TextStyle(fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,)),
                              ],
                            ),
                           // SizedBox(height: 10,),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("E-Mail",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),

                                SizedBox(width: overflow,
                                    child:leadDetailModel.email.toString()==""?const Text('N/A'): Text(leadDetailModel.email.toString(),style: const TextStyle(fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Contact No.",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.contactNo.toString()==""?const Text('N/A'): Text(leadDetailModel.contactNo.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Alternate No.",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.alternateNo.toString()==""?const Text('N/A'): Text(leadDetailModel.alternateNo.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Address",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.address.toString()==""?const Text('N/A'): Text(leadDetailModel.address.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,),),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("State",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.state.toString()==""?const Text('N/A'): Text(leadDetailModel.state.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),

                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Lead Source",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.leadSource.toString()==""?const Text('N/A'): Text(leadDetailModel.leadSource.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Company",style: TextStyle(fontSize: fontSize))),
                                Text(': ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.companyName.toString()==""?const Text('N/A'): Text(leadDetailModel.companyName.toString(),style: const TextStyle(fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Website",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width:overflow,
                                    child:leadDetailModel.website.toString()==""?const Text('N/A'): Text(leadDetailModel.website.toString(),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Industry Type",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.industryType.toString()==""?const Text('N/A'): Text(leadDetailModel.industryType.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width:width ,
                                    child: Text("Assigned\nAgent",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child: Text(assignedAgentName.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Status",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child: Text(leadDetailModel.leadStatus.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Status Reason",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.statusReason.toString()==''?const Text('N/A'): Text(leadDetailModel.statusReason??"NA",style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Quality",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child:leadDetailModel.leadquality.toString()==""?const Text('N/A'): Text(leadDetailModel.leadquality.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            Row(
                              children: [
                                SizedBox(width: width,
                                    child: Text("Product",style: TextStyle(fontSize: fontSize))),
                                Text(' : ',style: TextStyle(fontSize: fontSize)),
                                SizedBox(width: overflow,
                                    child: Text(leadDetailModel.product.toString()==''?"N/A":leadDetailModel.product.toString(),style: const TextStyle(fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,)),
                              ],
                            ),
                             Divider(color: dividerColor,),
                            InkWell(
                              onTap: (){
                                showDialog(context: context, builder: (BuildContext ctx){
                                  return Dialog(
                                    child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(leadDetailModel.description.toString())),
                                  );
                                });
                              },
                              child: Row(
                                children: [
                                  SizedBox(width: width,
                                      child: Text("Description",style: TextStyle(fontSize: fontSize))),
                                  Text(' : ',style: TextStyle(fontSize: fontSize)),
                                  SizedBox(width: overflow,
                                      child:leadDetailModel.description.toString()==''? const Text('N/A'):Text(leadDetailModel.description.toString(),style: const TextStyle(fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,)),
                                ],
                              ),
                            ),
                             Divider(color: dividerColor,),
                            InkWell(
                              onTap: (){
                                showDialog(context: context, builder: (BuildContext ctx){
                                  return Dialog(
                                    child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(leadDetailModel.message.toString())),
                                  );
                                });
                              },
                              child: Row(
                                children: [
                                  SizedBox(width: width,
                                      child: Text("Message",style: TextStyle(fontSize: fontSize))),
                                  Text(' : ',style: TextStyle(fontSize: fontSize)),
                                  SizedBox(width: overflow,
                                      child:leadDetailModel.message.toString()==''? const Text('N/A',style: TextStyle(fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,):Text(leadDetailModel.message.toString(),style: const TextStyle(fontSize: 15,overflow: TextOverflow.ellipsis),maxLines: 2,)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ),

                  // activity

                  Container(
                    margin: const EdgeInsets.only(left: 8.0,bottom: 10.0,right: 8.0),
                    padding: const EdgeInsets.only(left: 10.0,right: 10.0),
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
                          offset: Offset(0,2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('Activity : ',style: TextStyle(fontSize: 18),),TextButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewActivityPAge(event: leadDetailModel.eventDetails,)));
                        }, child: Text('View',style: TextStyle(fontSize: 16,color: mColor))),
                        Expanded(child: Container()),
                        IconButton(onPressed: (){
                          showAddEventWidgets(context);
                        }, icon: const Icon(Icons.add,color: Colors.orange,)),
                      ],
                    ),),

                  //add comment

                  Container(
                    margin: const EdgeInsets.only(left: 8,bottom: 10,right: 8),
                    //padding: EdgeInsets.only(bottom: 30),
                    height: 210, //275
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
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                           // height: 50,
                            child: const Text('Add Comment', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black87),),
                          ),
                        ),
                        // Divider(color: Colors.black87,),

                        Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:  Border.all(color:Colors.black26)
                          ),
                          child: TextField(
                            autofocus: false,
                            controller: commentController,
                             maxLines: 3,
                            decoration: const InputDecoration(
                                hintText:"Enter Your Text",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                )
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.all(5),
                        //   margin: const EdgeInsets.all(5),
                        //   height: 50,
                        //   decoration: BoxDecoration(
                        //       border:  Border.all(color:Colors.black26,)
                        //   ),
                        //   child:Row(
                        //     children: [
                        //       OutlinedButton(
                        //         style: ElevatedButton.styleFrom(
                        //           foregroundColor: Colors.black, backgroundColor: Colors.grey, // Background color
                        //         )  ,
                        //         onPressed: (){
                        //           _pickFile();
                        //         },child: const Text('Choose File'),),
                        //       const SizedBox(width: 10,),
                        //       file.toString()!='null'? Expanded(
                        //         child: InkWell(onTap: (){
                        //           viewFile();
                        //          },
                        //              child:Text(file.name.toString(),overflow: TextOverflow.ellipsis,)),
                        //       ):const Text('No File Chosen')
                        //     ],
                        //   ),
                        // ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.all(5),
                          height: 50,
                          decoration: BoxDecoration(
                            border:  Border.all(color:Colors.black26),

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent, // Background color
                                  )  ,
                                  onPressed: (){
                                    addCommentDialog();
                                  }, child: const Text('Add'))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // recent comment

                  Container(
                    margin: const EdgeInsets.only(left: 8,bottom: 8,right: 8),
                    padding: const EdgeInsets.only(left: 8,bottom: 8),
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
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    //  mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                        //  crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            const Text('Recent Comment', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black87),),
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowAllComments(comments: leadDetailModel.comment,)));
                          }, child: const Text('View All',style: TextStyle(color: Colors.orange),)),
                          ],
                        ),
                       commentLength>0? Row(children: [
                          Column(
                            children: [
                              Container(height: 40,width:40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0),color: Colors.yellow,),
                                child: Center(child:Text('${leadDetailModel.comment[0]['firtName']}',style: const TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),)),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              //padding: EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text('${leadDetailModel.comment[0]['agentName']}',style: const TextStyle(color: Colors.blueAccent),),
                                  // const SizedBox(width: 4,),
                                    Text(' , ${leadDetailModel.comment[0]['timeStamp']}',style: const TextStyle(),),
                                  ],),
                                  Text('${leadDetailModel.comment[0]['comment']}'),
                                ],
                              ),
                            ),
                          )
                        ],):const Text('No Recent Comment'),
                      ],
                    ),
                  ),

                  // comments

                  // Container(
                  //   margin: const EdgeInsets.only(left: 8,bottom: 10,right: 8),
                  //   padding: const EdgeInsets.only(top: 7,left: 8),
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     border: Border.all(
                  //       color: Colors.grey,
                  //       width: 2,
                  //     ),
                  //     boxShadow: const [
                  //       BoxShadow(
                  //         color: Colors.grey,
                  //         offset: Offset(2, 2),
                  //         blurRadius: 4,
                  //       ),
                  //     ],
                  //   ),
                  //   child:Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     //mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       const Text('Comments View', style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold,color: Colors.black87),),
                  //       const SizedBox(height: 10,),
                  //       if (commentLength>0) SizedBox(
                  //         height: 200,
                  //         child: ListView.builder(itemCount: commentLength,
                  //           itemBuilder: (BuildContext context, int index) {
                  //          return Row(
                  //            children: [
                  //            Column(
                  //              children: [
                  //                Container(height: 40,width:50,color:index<=14?colors[index]:Colors.lightBlueAccent.shade400,
                  //                  child: Center(child:Text('${leadDetailModel.comment[index]['firtName']}',style: const TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),)),
                  //                ),
                  //              ],
                  //            ),
                  //            Expanded(
                  //              child: Container(
                  //                padding: const EdgeInsets.all(10.0),
                  //                child: Column(
                  //                  mainAxisAlignment: MainAxisAlignment.start,
                  //                  crossAxisAlignment: CrossAxisAlignment.start,
                  //                  children: [
                  //                    Row(
                  //                      mainAxisAlignment: MainAxisAlignment.start,
                  //                    children: [
                  //                      Text('${leadDetailModel.comment[index]['agentName']}',style: const TextStyle(color: Colors.blueAccent),),
                  //                     // const SizedBox(width: 4,),
                  //                      Text(' , ${leadDetailModel.comment[index]['timeStamp']}',style: const TextStyle(),),
                  //                    ],),
                  //                    InkWell(onTap: (){
                  //                      setState(() {
                  //                         ind=index;
                  //                        showMsg=TextOverflow.visible;
                  //                      });
                  //                    },
                  //                        child: Text('${leadDetailModel.comment[index]['comment']}',
                  //                          style: const TextStyle(fontSize: 14),overflow:index==ind? showMsg:TextOverflow.ellipsis)),
                  //                  ],
                  //                ),
                  //              ),
                  //            ),
                  //              const Divider(color: Colors.orange,),
                  //            ],);
                  //         },
                  //         ),
                  //       ) else Container(
                  //        padding: const EdgeInsets.all(10.0),
                  //          child: const Text('No Comment')),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ) :loadError? Center(child: CircularProgressIndicator(strokeWidth: 2,color: mColor,)):const Center(child: Text('Failed to Load Data')),
            ),
          ),
        ));
  }
}