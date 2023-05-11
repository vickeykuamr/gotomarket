// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;
// import '../LoginPages.dart';
// import 'LeadDetails.dart';
//
// class LeadsCard extends StatefulWidget {
//   final leadSource;
//   final status;
//   const LeadsCard({Key? key,required this.leadSource, required this.status, required }) : super(key: key);
//
//   @override
//
//   State<LeadsCard> createState() => _CardListState();
// }
//
// class _CardListState extends State<LeadsCard> {
//
//   var contactNumber;
//   List jsonDataList=[];
//   var nullJsonDataList;
//   late SharedPreferences sharedPreferences;
//   var getCookies;
//   var agentSize;
//   var agentPage;
//
//   Future<void> getSharedPreference()async{
//     try{
//       sharedPreferences=await SharedPreferences.getInstance();
//       getCookies= sharedPreferences.getString('cookie');
//       agentPage= sharedPreferences.getString('pageNumber');
//       agentSize= sharedPreferences.getString('size');
//       print("kkkkk $getCookies");
//       getLeadsDetail();
//
//     }catch(e){
//
//     }
//   }
//
//   bool isLoading=false;
//
//   _launchEmail(String emails)async {
//     log(emails);
//     String email = Uri.encodeComponent("mail@fluttercampus.com");
//     String subject = Uri.encodeComponent("Hello");
//     String body = Uri.encodeComponent("Hi!");
//     print(subject); //output: Hello%20Flutter
//     Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
//     if (await launchUrl(mail)) {
//     //email app opened
//     }else{
// ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $email")));
//     }
//   }
//   _launchWhatsapp(var number) async {
//     var whatsappAndroid =Uri.parse("whatsapp://send?phone=$number&text=hello");
//     if (await canLaunchUrl(whatsappAndroid)) {
//       await launchUrl(whatsappAndroid);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(
//           content: Text("WhatsApp is not installed on the device $number"),
//         ),
//       );
//     }
//   }
//   _launchSms(var number) async {
//     try {
//       if (Platform.isAndroid) {
//         String uri = 'sms:$number?body=${Uri.encodeComponent("Hello there")}';
//         await launchUrl(Uri.parse(uri));
//       } else if (Platform.isIOS) {
//         String uri = 'sms:$number&body=${Uri.encodeComponent("Hello there")}';
//         await launchUrl(Uri.parse(uri));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(
//           content: Text('Some error occurred. Please try again! $number'),
//         ),
//       );
//     }
//   }
//   _launchPhone(var number)async{
//     var url = "tel:$number";
//     if(Platform.isAndroid){
//       log('dfd');
//       if (await canLaunch(url)) {
//       await launch(url);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $url")));
//       }
//       }else{
//       if (await canLaunch(url)) {
//       await launch(url);
//       }else{
// ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $url")));
//       }
//       }}
//
//   Future<void> getNullValue()async{
// log('dfdgfdg');
//     var headers = {
//       'Content-Type': 'application/json',
//       'Cookie':'$getCookies',
//       //  'Cache-Control':'no-cache'
//     };
//     var request = http.Request('GET', Uri.parse('https://player.go2market.in:5001/api/leadDetail?sourceLead=null&status=open&pageNumber=$agentPage&size=30'));
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//
//     if (response.statusCode == 200) {
//       var res= await response.stream.bytesToString();
//       var jsonData=jsonDecode(res);
//
//       nullJsonDataList=jsonData['content'];
//
//       var kl=jsonData['content'];
//
//      jsonDataList.add(kl);
//
//       log('dkljfkfjdh ${kl}');
//       setState(() {
//       });
//       log(jsonDataList.toString());
//     }
//     else {
//       print(response.reasonPhrase);
//     }
//   }
//
//   void getLeadsDetail()async{
//     jsonDataList.clear();
//     try{
//       var headers = {
//         'Content-Type': 'application/json',
//         'Cookie':'$getCookies',
//         //'Cache-Control':'no-cache'
//       };
//       var request = http.Request('GET', Uri.parse('https://player.go2market.in:5001/api/leadDetail?sourceLead=${widget.leadSource}&status=${widget.status}&pageNumber=1&size=30'));
//       request.headers.addAll(headers);
//       http.StreamedResponse response = await request.send();
//       if (response.statusCode == 200) {
//         var res= await response.stream.bytesToString();
//         var jsonData=jsonDecode(res);
//         // jsonDataList=jsonData['content'];
//
//         jsonDataList.add(jsonData['content']);
//
//         log(jsonDataList.toString());
//
//          //var kk=jsonDataList;
//       //   Map<String ,dynamic> jsonMap=jsonDecode(kk);
//        //  MyLeadCartModel model=MyLeadCartModel.fromJson(jsonMap);
//          isLoading=true;
//        /// setState(() {}
//         //
//         if(widget.leadSource=='walkin' && widget.status=='open'){
//           getNullValue();
//         }else{
//           setState(() {
//           });
//         }
//       }
//       else {
//         print(response.reasonPhrase);
//         if(response.reasonPhrase=='Unauthorized'){
//           showDialog(barrierDismissible: false,
//               context: context, builder: (BuildContext ctx){
//                 return AlertDialog(
//                   title: const Text('Season Expire'),
//                   actions: [
//                     TextButton(onPressed: (){
//                       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=>const LoginPage1()), (route) => false);
//                     }, child: const Text('Login Again')),
//                   ],
//                 );
//               });
//           print('expire');
//         }
//         setState(() {
//           isLoading=true;
//         });
//       }
//     }catch(e){
//       print(e.toString());
//       setState(() {
//         isLoading=true;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     print(widget.leadSource);
//     print(widget.status);
//     getSharedPreference();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var width=MediaQuery.of(context).size.width;
//     return Scaffold(
//         appBar: AppBar(title: const Text('My Leads'),centerTitle: true,),
//         body: Center(
//              child:isLoading? Container(
//     padding: const EdgeInsets.all(10.0),
//     width: double.infinity,
//    height: double.infinity,
//     child:jsonDataList!=null? ListView.builder(
//     itemCount: jsonDataList[0].length,
//     itemBuilder: (context,index){
//     return GestureDetector(
//       onTap: (){
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>LeadsDetails(leadId: jsonDataList[index][0]['leadId'].toString(), status: jsonDataList[index][0]['status'].toString(), sourceLead: widget.leadSource,nullSouceName: jsonDataList[index][0]['sourceLead'].toString(),)));
//         print(index.toString());
//       },
//       child: Container(
//         // border design
//     //  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0),border: Border.all(color: Colors.black12),color: Colors.orange),
//    //  padding: EdgeInsets.all(0.5),
//       //  margin: const EdgeInsets.only(bottom: 5),
//         child: Card(
//       shadowColor: Colors.blue.shade300,
//       elevation: 1.0,
//         child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5.0),
//       margin: const EdgeInsets.only(bottom: 5),
//         child: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(color: Colors.white70,
//       padding: const EdgeInsets.all(5.0),
//           child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//           Text('Status :  ${jsonDataList[0][index]['status'].toString()}',style: const TextStyle(fontSize: 14),),const SizedBox(height: 10,),
//           Expanded(child: Container()), Text('${jsonDataList[0][index]['timeStamp'].toString()}',style: const TextStyle(fontSize: 14),),
//       ],
//       ),
//            ),const SizedBox(height: 5,),
//         Text('Leads No. : ${jsonDataList[0][index]['leadId'].toString()}',style: const TextStyle(fontSize: 20),),const SizedBox(height: 10,),
//          Text('Name : ${jsonDataList[0][index]['name'].toString()}',style: const TextStyle(fontSize: 18),),const SizedBox(height: 12,),
//           Container(
//         padding: const EdgeInsets.only(right: 10.0),
//         decoration: BoxDecoration(boxShadow: [
//           const BoxShadow(
//             color: Colors.black12,blurRadius: 1,spreadRadius: 2,offset: Offset(0,1)
//           )
//         ],
//             border: Border.all(color: Colors.black12),borderRadius: BorderRadius.circular(10.0)),
//             child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//          children: [
//               IconButton(
//               onPressed: () {
//         log(jsonDataList[index][0]['contact']);
//
//             _launchPhone(jsonDataList[0][index]['contact']);
//               }, icon: const Icon(Icons.call,color: Colors.blue,size: 30,),),const SizedBox(width: 10,),
//               IconButton(icon: const Icon(Icons.sms,color: Colors.blueGrey,size: 30,),
//               onPressed: ()async {
//                 _launchSms(jsonDataList[0][index]['contact']);
//               },
//               ),const SizedBox(width: 10,),
//               IconButton(icon: Icon(Icons.email,color: Colors.red.shade600,size: 30,),
//               onPressed: ()async {
//                 _launchEmail(jsonDataList[0][index]['email']);
//               },
//               ),const SizedBox(width: 10,),
//               GestureDetector(onTap:(){
//                 log('whatapps');
//                 _launchWhatsapp(jsonDataList[0][index]['contact']);
//                 log(jsonDataList[0][index]['contact'].toString());
//               },
//                   child: Image.asset('assets/whatsapp240.png',height: 36,width: 36,)),
//                // SizedBox(width: 1,),
//               ],
//               ),
//             )
//           ],
//           ),
//           ),
//           ),
//           ),
//         );
//
//     }):const Center(child: Text('No Records Found')),
//           ):const CircularProgressIndicator(),
//     ),
//     );
//   }
// }
