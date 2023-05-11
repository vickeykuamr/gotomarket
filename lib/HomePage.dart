import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gm/ApiService/BaseUrl.dart';
import 'package:gm/SessionPage/MySession.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import 'LoginPages.dart';
import 'Screens/AddLeads.dart';
import 'Screens/LeadStatusPage.dart';

var logo=Image.asset('assets/logo2.png');
var mColor=Colors.orange[700];

class LeadCounterPage extends StatefulWidget {
 const LeadCounterPage({Key? key,}) : super(key: key);

  @override
  State<LeadCounterPage> createState() => _DashboardState();
}

class _DashboardState extends State<LeadCounterPage> {

  var nullCount=0;
  var leadCounterApiUrl='${BaseUrl.apiBaseUrl}/leadCounter';
  //var iconList=['assets/logo/noimage96.png','assets/logo/contacts240.png','assets/logo/facebook48.png','assets/logo/google48.png','assets/logo/noimage96.png','assets/logo/phone48.png',
  // 'assets/logo/noimage96.png','assets/logo/twitter48.png','assets/logo/walking48.png','assets/logo/mail48.png',"assets/whatsapp240.png","assets/logo/mail48.png"];

  late SharedPreferences sharedPreferences;
  var myLeadCountList=[];
  var myLeadSourceList=[];
  var myLeadImageUrl=[];
  late List<dynamic> leadLength=[];
   String? getCookies;
   bool isLoading=false;
   bool loadError=true;

   var userEmail;
   String? userPass;
   String? userFirstName;
   String? splitName;
   var cTime;

  String msg='';
  String msg1='';

   List<dynamic> storeNullValue=[];
   var dropdownList;

  Future<void> getDropdownValue()async{
    try{
      var headers = {
        'cookie':'$getCookies'
      };
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/dropdown'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var result=await response.stream.bytesToString();
        if(result!='{"content":[]}'){
          var jsonData=jsonDecode(result);
          dropdownList=jsonData['content'];
          log(dropdownList.toString());
        }
      }
    }catch(e){
      if(e.toString()=='Unauthorized'){
        MySessions.sessionExpire(context);
      }
    }
  }

  Future<void> getSharedPreference()async{
    sharedPreferences=await SharedPreferences.getInstance();
   getCookies= sharedPreferences.getString('cookie');
   userEmail=sharedPreferences.getString('userEmail');
   userPass=sharedPreferences.getString('userPass');
   userFirstName=userEmail.toString().substring(0,1);
    log("cookies $getCookies");
    final split=userEmail.split('@');
    splitName=split[0];
    if (kDebugMode) {
      print(split[0]);
    }
    getLeadCounter();
  }


  void getLeadCounter()async{
   // errorLoadSource=false;
    myLeadSourceList.clear();
    myLeadCountList.clear();
    myLeadImageUrl.clear();
    leadLength.clear();
    storeNullValue.clear();
    leadLength.clear();
    try{
      var headers = {
        'Content-Type': 'application/json',
        'Cookie':"$getCookies",
        //'Cache-Control':'no-cache'
      };
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/leadCounter'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        errorLoadSource=false;

      var res= await response.stream.bytesToString();
      var jsonData=jsonDecode(res);
      var jsonData1=jsonData['content'];
      log("data1 $jsonData1");

      if(jsonData1.toString()!='null'){
        var len=jsonData1.length;
        log("length $len");
      for(int i=0; i<len;i++){
        // myLeadCountList.add(jsonData1[i]['count']);
        // myLeadSourceList.add(jsonData1[i]['sourceLead']);
        // log(myLeadSourceList.toString());

        var checkNull=jsonData1[i]['sourceLead'];
        log("null  $checkNull");
        if(checkNull=='null'){
          storeNullValue.add(jsonData1[i]['count']);
          log("lead $storeNullValue");
        }else{
          if(checkNull=="walkin"){
          //storeNullValue.length!=0
            if(storeNullValue.isNotEmpty){
              try{
                nullCount=0;
                var storeNull;
                storeNull=jsonData1[i]['count'];
                log("store nul ${storeNullValue.length}");
                for(int k=0;k<storeNullValue.length;k++){
                  log('message');
                  nullCount=nullCount+int.tryParse(storeNullValue[k])!;
                  var total=0;
                  total =int.tryParse(storeNull)! + nullCount;
                  myLeadCountList.add(total);
                  //   leadLength.add(k);
                  myLeadSourceList.add(jsonData1[i]['sourceLead']);
                  myLeadImageUrl.add(jsonData1[i]['sourceUrl']);
                  log("list1 $myLeadSourceList");
                  log(total.toString());
                }
              }catch(e){
                log(" catch  $e");
              }
            }else{
        log("image url $jsonData1[i]['sourceUrl']");
        myLeadCountList.add(jsonData1[i]['count']);
        myLeadSourceList.add(jsonData1[i]['sourceLead']);
        myLeadImageUrl.add(jsonData1[i]['sourceUrl']);
            }
          }else{
          //  leadLength.add(i);
            myLeadCountList.add(jsonData1[i]['count']);
            myLeadSourceList.add(jsonData1[i]['sourceLead']);
            myLeadImageUrl.add(jsonData1[i]['sourceUrl']);
            log("list $myLeadSourceList");
            setState((){
              isLoading=true;
            });
          }
        }
      }
      }else{
        setState(() {
          msg='No Leads Found';
          isLoading=true;
        });
      }

      log("length ${leadLength.length}");
      log("length 2 $myLeadImageUrl");
       // getDropdownValue();
        getDropdownValue();
      }
      else {
      log("res ${response.reasonPhrase}");
        if(response.reasonPhrase=='Unauthorized'){
          MySessions.sessionExpire(context);
        }else{
          setState(() {
            msg='Failed to load Lead refresh now';
            isLoading=true;
          });
          // if(response.reasonPhrase.toString()=='player.go2market.in'){
         // noConnection();
         // }
        }
      }
    }on TimeoutException catch (_) {
     // isLoading=true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your connection has timed out')));
     msg="Connection timed out";
      setState(() {
        errorLoadSource=true;
      });
    //  closeDialog();
      if (kDebugMode) {
        print("Your connection has Timed Out");
      }
    }on SocketException catch (e) {
    //  isLoading=true;
    //  NoNetworks.noConnection(context);
      log('expire');
      isLoading=false;

      //isLoading=false;
      // loadError=false;
      log(e.toString());
     if(e.toString()=='Connection timed out'){
       msg="Connection timed out";
       setState(() {
         isLoading=false;
         errorLoadSource=true;
       });
     }else{
       msg="No Internet Connection";
      msg1='Please connect to the internet and try again.';
     setState(() {
       isLoading=false;
         errorLoadSource=true;
       });
     }
    }
  }

  bool errorLoadSource=false;

  Widget _errorMsgShow(){
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_sharp,size: 40,),
          const SizedBox(height: 6,),
          Text(msg.toString(),style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 18),),const SizedBox(height: 6,),
          Text(msg1.toString(),style: const TextStyle(fontWeight: FontWeight.w500),),const SizedBox(height: 6,),
          ElevatedButton(onPressed: (){
            setState(() {
              errorLoadSource=false;
            });
            getLeadCounter();
          }, child: Text('try again',style: TextStyle(color:mColor),),),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    isLoading=false;
    getLeadCounter();
  }

  @override
  void initState() {
    super.initState();
    getSharedPreference();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<bool> onWillPop(){
    DateTime now = DateTime.now();
    if (cTime == null || now.difference(cTime) > const Duration(seconds: 2)) {
      cTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: const Center(child: Text('Press Again to Exit')),backgroundColor: Colors.orange.shade600,)
      );return Future.value(false);
    }return Future.value(true);
  }

  Future<void> logOut() async {
    showDialog(barrierDismissible: false,
        context: context, builder: (BuildContext ctx){
      return WillPopScope(
        onWillPop: ()async=>false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Row(
           // mainAxisAlignment: MainAxisAlignment.,
            children: const [
              SizedBox(width: 30,height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2,)),SizedBox(width: 10,),Text('Logging Out...'),
            ],
          ),
        ),
      );
    });
    try{
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/logout'));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 401) {
        closeDialog();
        var logOuts= await response.stream.bytesToString();
        var json =jsonDecode(logOuts);
        var data=json['title'];
        if(data=='Unauthorized'){
          log('log out');
          sharedPreferences.clear();
          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context)=>const LoginPage1(alreadyLogin: false,)), (route) => false);
        }else{
          closeDialog();
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Failed to Log Out')));
        }
      }
      else {
       closeDialog();
       ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Failed to Log Out')));
        log(response.reasonPhrase.toString());
      }
    }on TimeoutException catch (_) {
      closeDialog();
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Connection timed out')));
      if (kDebugMode) {
        print("Your connection has Timed Out");
      }
    }on SocketException catch (e) {
      if(e.toString()=='Connection timed out'){
        closeDialog();
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Connection timed out')));
      }else{
        closeDialog();
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('You are not connected to internet')));
        if (kDebugMode) {
          print("You are not connected to internet");
        }
      }
    }
  }

  void closeDialog(){
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
    //  drawerScrimColor: Colors.white,
      appBar: AppBar(
        foregroundColor:mColor,
      title: SizedBox(width: 150,
          child: Image.asset('assets/logo2.png',)),
      //  title: const Text("Go2Market",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      //   actions: [
      //     IconButton(onPressed: (){
      //       setState(() {
      //         isLoading=false;
      //       });
      //       getLeadCounter();
      //     }, icon:isLoading? const Icon(Icons.refresh_sharp,color: Colors.white,):const Icon(Icons.circle_outlined,color: Colors.cyan,)),
      //      PopupMenuButton(
      //        color: Colors.white,
      //        position: PopupMenuPosition.under,
      //     itemBuilder: (context){
      //       return[
      //         const PopupMenuItem<int>(
      //           value: 1,
      //             child: Text('Log Out')),
      //         // const PopupMenuItem<int>(
      //         //     value: 2,
      //         //     child: Text('search')),
      //       ];
      //     },
      //       onSelected: (value){
      //       if(value==1){
      //         logOut();
      //       }else if(value==2){
      //
      //
      //     //    MySessions.sessionExpire(context);
      //
      //      //  MySessions.sessionExpire(context);
      //        // Navigator.push(context, MaterialPageRoute(builder: (context)=>const SendEmail()));
      //       }
      //   },
      // )
      //   ],
      ),
      drawer: Drawer(
       // width: MediaQuery.of(context).size.width*0.7,
        child: Column(
          children: [
            Stack(fit: StackFit.loose,
                alignment: Alignment.topRight,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                  ), //BoxDecoration
                  child: Column(
                    children: [
                  Container(
                      width: double.infinity,alignment: Alignment.center,
                      child:SizedBox(height: 36,child: logo)
                      //const Text('GO2MARKET',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500,color: Colors.white),)
                      ),
                      const SizedBox(height: 10.0,),
                      CircleAvatar(child: Text('$userFirstName',style: const TextStyle(fontSize: 24,color: Colors.orange),),),const SizedBox(height: 5,),
                      Text('$splitName',style: const TextStyle(fontSize: 16,color: Colors.white),),const SizedBox(height: 5,),
                      Text('$userEmail',style: const TextStyle(fontSize: 14),),
                    ],
                  ), //UserAccountDrawerHeader
                ),
                 GestureDetector(
                     onTap: (){
                     Navigator.pop(context);
                     },
                     child: Container(margin: const EdgeInsets.only(top: 30.0,right: 5.0),
                         child: const Icon(Icons.close,size: 22,color: Colors.white,)),
                   ),
              ]
            ),

//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text(' My Profile '),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.book),
//               title: const Text(' My Course '),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.workspace_premium),
//               title: const Text(' Go Premium '),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.video_label),
//               title: const Text(' Saved Videos '),
//               onTap: () {
//                 print('object');
//                 MySessions.sessionExpire(context);
//                // Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text(' Edit Profile '),
//               onTap: () {
//                 var names=userEmail;
//                 final split=names.split('@');
//                 print(split[0]);
// //                Navigator.pop(context);
//               },
//             ),


            Expanded(child: Container()),
            ListTile(
              leading: const Icon(Icons.logout,color: Colors.orange,),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                logOut();
              },
            ),
            const Divider(),
            const Text('App v. 1.0.0',style: TextStyle(color: Colors.orange),),
            const SizedBox(height: 5.0,)
          ],
        ),
      ),

      body: WillPopScope(
        onWillPop: onWillPop,
        child: SafeArea(
          child:errorLoadSource ? _errorMsgShow():(isLoading)? LiquidPullToRefresh(
           // springAnimationDurationInMilliseconds: 2000,
            backgroundColor: Colors.white,
            color: Colors.orange.shade300,
            showChildOpacityTransition: false,
            onRefresh: () {
              return _refresh();
              },
            child:myLeadSourceList.isNotEmpty? Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                  itemCount: myLeadSourceList.length,
                  itemBuilder: (context, index){
                    return InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LeadStatus(leadSource:myLeadSourceList[index],nullCount: nullCount,logo: myLeadImageUrl[index],)));
                      },
                      child: Card(
                        elevation: 1,
                        color: Colors.white,shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),borderRadius: BorderRadius.circular(7)),
                        child: Container(
                          height: 40,
                          width:double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                          child: Row(
                            children: [
                              SizedBox(height: 30,width: 30,
                                  child:myLeadImageUrl[index].toString()!=''?SvgPicture.network(myLeadImageUrl[index]):const Icon(Icons.image_not_supported_outlined),),
                              const SizedBox(width: 5,),
                              Expanded(child: Text(myLeadSourceList[index].toString())),
                             Text('[ ${myLeadCountList[index].toString()} ]'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ) :  Center(child: Text(msg.toString())),
          ): Center(child: CircularProgressIndicator(strokeWidth: 2,color: mColor,),),
        ),
      ),
       floatingActionButton:isLoading? FloatingActionButton(
        backgroundColor:mColor,
        onPressed: () {
          if(errorLoadSource){
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text("Please Connect Internet")));
          }else{
            Navigator.push(context, CupertinoPageRoute(builder: (context)=>AddLeads(sourceList: myLeadSourceList,dropdownList: dropdownList,)));
          }
        },
      child: const Icon(Icons.add,color: Colors.white,),):null,
    );
  }
}
