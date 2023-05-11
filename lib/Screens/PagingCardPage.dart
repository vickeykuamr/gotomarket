import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gm/Models/MyLeadCardModel.dart';
import 'package:gm/SessionPage/MySession.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../ApiService/BaseUrl.dart';
import '../EmailPage.dart';
import '../HomePage.dart';
import '../NetworkPage/NoNetwork.dart';
import '../SmsPage.dart';
import 'LeadDetails.dart';

class PagingLeadsCard extends StatefulWidget {
  final leadSource;
  final status;
  const PagingLeadsCard({Key? key,required this.leadSource, required this.status, required }) : super(key: key);

@override

State<PagingLeadsCard> createState() => _CardListState();
}

class _CardListState extends State<PagingLeadsCard> {

  var inputText=TextEditingController();

String? contactNumber;
List jsonDataList=[];
var nullJsonDataList;
late SharedPreferences sharedPreferences;
String? getCookies;
String msg='';
String msg1='';
bool  errorLoadSource=false;

var checkSearchVar='Filter';
// var agentSize;
// var agentPage;

bool isLoadingNullValue=false;
bool loadError=true;

Future<void> getSharedPreference()async{
try{
sharedPreferences=await SharedPreferences.getInstance();
getCookies= sharedPreferences.getString('cookie');
// agentPage= sharedPreferences.getString('pageNumber');
// agentSize= sharedPreferences.getString('size');
if (kDebugMode) {
  print("cookies $getCookies");
}
_firstLoad();
}catch(e){
  log(e.toString());
}
}

bool isLoading=false;

// _launchEmail(String emails)async {
// //log(emails);
// String email = Uri.encodeComponent("go2market@email.com");
// String subject = Uri.encodeComponent("Hello");
// String body = Uri.encodeComponent("Hi!");
//
// Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
// if (await launchUrl(mail)) {
//   await launchUrl(mail,
//   mode: LaunchMode.externalApplication);
//
// //email app opened
// }else{
// ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $email")));
// }
// }

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
showScaffold("Whatsapp not installed. $number'");

//ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Whatsapp not installed. $number'),),);
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
// _launchSms(var number) async {
// try {
// if (Platform.isAndroid) {
// String uri = 'sms:$number?body=${Uri.encodeComponent("Hello there")}';
// await launchUrl(Uri.parse(uri),mode: LaunchMode.externalApplication);
// } else if (Platform.isIOS) {
// String uri = 'sms:$number&body=${Uri.encodeComponent("Hello there")}';
// await launchUrl(Uri.parse(uri));
// }
// } catch (e) {
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(
// content: Text('Some error occurred. Please try again! $number'),
// ),
// );
// }
// }
_launchPhone(var number)async{
var url = "tel:$number";
if(Platform.isAndroid){
log('dfd');
if (await canLaunch(url)) {
await launch(url);
} else {
showScaffold("Unable to call $url");

//ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $url")));
}
}else{
if (await canLaunch(url)) {
await launch(url);
}else{
  showScaffold("Unable to call $url");
//ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to call $url")));

}
}
}

void showScaffold(msgs){
ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.orange,content: Text(msgs.toString())));

}

Future<void> getNullValues()async{
isLoadingNullValue=true;
var headers = {
'Content-Type': 'application/json',
'Cookie':'$getCookies',
//  'Cache-Control':'no-cache'
};
try{
var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/leadDetail?sourceLead=null&status=open&pageNumber=$_page&size=30'));
request.headers.addAll(headers);
http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
var res= await response.stream.bytesToString();
var jsonData=jsonDecode(res);

nullJsonDataList=jsonData['content'];
var kl=jsonData['content'];

for(int i=0;i<kl.length;i++){
log(i.toString());
log(kl[i]['name']);
dataList.add(kl[i]);
}
_page+=1;
setState(() {
});
log('null value : ${kl.toString()}');
}
else {
if (kDebugMode) {
  print(response.reasonPhrase);
}
}
}catch(e){
  log('message');
 log(e.toString());
_hasNextPage = false;
setState(() {
isLoading=true;
_isLoadMoreRunning = false;
});
//_controller.removeListener(getNullValue);
}
}

@override
void initState() {
super.initState();
getSharedPreference();
_controller = ScrollController()..addListener(_loadMore);
}

late MyLeadCartModel model;

//paging

 List dataList=[];
String noDataFound='';
// We will fetch data from this Rest api

// At the beginning, we fetch the first 20 posts
int _page = 1;
// you can change this value to fetch more or less posts per page (10, 15, 5, etc)
// There is next page or not
bool _hasNextPage = true;

// Used to display loading indicators when _firstLoad function is running
bool _isFirstLoadRunning = true;

// Used to display loading indicators when _loadMore function is running
bool _isLoadMoreRunning = false;

final _baseUrl = '${BaseUrl.apiBaseUrl}/leadDetail?sourceLead=';

void _firstLoad() async {
// setState(() {
// _isFirstLoadRunning = true;
// });
_isFirstLoadRunning = true;

try{
var headers = {
'Content-Type': 'application/json',
'Cookie':'$getCookies',
//'Cache-Control':'no-cache'
};
var request = http.Request('GET', Uri.parse('$_baseUrl${widget.leadSource}&status=${widget.status}&pageNumber=$_page&size=30'));
log(request.toString());
request.headers.addAll(headers);
http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
var res= await response.stream.bytesToString();
var jsonData=jsonDecode(res);
jsonDataList.add(jsonData['content']);
try{
  log(jsonDataList.toString());
  if(jsonDataList.toString()!='[null]'){
int k=0;
while(k<jsonDataList.length){
for(int i=0;i<jsonDataList[_page-1].length;i++){
dataList.add(jsonDataList[_page-1][i]);
k++;
}
}

filterData=dataList;

log("data li $dataList");
}else{
log('message');
//loadError=false;
isLoading=true;
showScaffold('No Records Found');
//ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('No Records Found',style: TextStyle(color: Colors.amber),))));
}

}catch(e){
  log(e.toString());
loadError=false;
isLoading=true;
showScaffold('Failed to load data Try again');
//ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('Failed to load data Try again',style: TextStyle(color: Colors.amber),))));
}
isLoading=true;
noDataFound='No Records Found';
}
else {
if (kDebugMode) {
  print(response.reasonPhrase);
}
if(response.reasonPhrase=='Unauthorized'){
MySessions.sessionExpire(context);
}
setState(() {
loadError=false;
isLoading=true;
});
}
}on TimeoutException catch (_) {
// isLoading=true;
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your connection has timed out')));
msg="Connection timed out";
setState(() {
errorLoadSource=true;
isLoading=false;
loadError=false;      });
//  closeDialog();
if (kDebugMode) {
  print("Your connection has Timed Out");
}
}on SocketException catch (e) {
//  isLoading=true;
//  NoNetworks.noConnection(context);
log('expire');
msg1='';
log(e.toString());
if(e.toString()=='Connection timed out'){
msg="Connection timed out";
setState(() {
errorLoadSource=true;
isLoading=false;
loadError=false;
});
}else if(e.toString()=="Failed host lookup: 'player.go2market.in'" || e.toString()=="No Internet Connection"){
msg="No Internet Connection";
msg1='Please connect to the internet and try again.';
setState(() {
errorLoadSource=true;
isLoading=false;
loadError=false;
});
}else{
setState(() {
isLoading=false;
loadError=false;
});
}
}
catch(e){
if (kDebugMode) {
  print("gg $e");
}
setState(() {
  loadError=false;
isLoading=true;
});
}

setState(() {
_isFirstLoadRunning = false;
});
}


int len=0;

@override
void dispose() {
// TODO: implement dispose
super.dispose();
_controller.removeListener(_loadMore);
}

@override
void setState(VoidCallback fn) {
if (mounted) {
super.setState(fn);
}
}

late ScrollController _controller;

void _loadMore() async {
  //log('message');
if (_hasNextPage == true &&
_isFirstLoadRunning == false &&
_isLoadMoreRunning == false &&
_controller.position.extentAfter < 30) {
setState(() {
_isLoadMoreRunning = true; // Display a progress indicator at the bottom
});
_page += 1;

log('pages no.  $_page');
int l=dataList.length;
log(l.toString());
// Increase _page by 1
try{
var headers = {
'Content-Type': 'application/json',
'Cookie':'$getCookies',
//'Cache-Control':'no-cache'
};
var request = http.Request('GET', Uri.parse('$_baseUrl${widget.leadSource}&status=${widget.status}&pageNumber=$_page&size=30'));
request.headers.addAll(headers);
http.StreamedResponse response = await request.send();
if (response.statusCode == 200) {
var res= await response.stream.bytesToString();
var jsonData=jsonDecode(res);
final List jsonDa=jsonData['content'];

log("data 2  $jsonDa");

if(jsonDa.toString()!='null'){
  jsonDataList.add(jsonData['content']);
  try{
int k=0;
while(k<jsonDa.length){
for(int i=0;i<jsonDataList[_page-1].length;i++){
dataList.add(jsonDataList[_page-1][i]);
//Map<String , dynamic> jsonMap=jsonDecode(jsonDataList[_page-1][i]);

model=MyLeadCartModel.fromJson(jsonDataList[_page-1][i]);
k++;
}
}
int l=dataList.length;
filterData=dataList;
log("list 1 $dataList");
log(l.toString());
}catch(e){
    showScaffold('All Fetch Data Error');
//    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('All Fetch Data Error',style: TextStyle(color: Colors.amber),))));
}
}else{
  log('all fetch data');
_hasNextPage = false;
}
isLoading=true;
_isLoadMoreRunning = false;
setState(() {
});
}
else {
if (kDebugMode) {
  print(response.reasonPhrase);
}
if(response.reasonPhrase=='Unauthorized'){
MySessions.sessionExpire(context);
}
setState(() {
isLoading=true;
_isLoadMoreRunning = false;
});
}
}catch(e){
  log('message');
  if(widget.leadSource=='walkinn' && widget.status=='openN'){
  log('null null null null');
  _page=1;
_controller.removeListener(_loadMore);
//_controller = ScrollController()..addListener(getNullValue);
//getNullValue();
}else{
  setState(() {
_hasNextPage = false;
isLoading=true;
_isLoadMoreRunning = false;
});
  }
log(e.toString());
}
}
}

// filtering data

late List<dynamic> filterData;

void isDataExist(String value) {

// try{
// if(value.startsWith('0') ||value.startsWith('1') ||value.startsWith('2') ||value.startsWith('3') ||value.startsWith('4')
// ||value.startsWith('5')||value.startsWith('6')||value.startsWith('7') ||value.startsWith('8')||value.startsWith('9')){
// searchElement(value.trim(), "leadId");
// }else{
// searchElement(value.trim(), 'name');
// }
// }catch(e){
//   log("search error $e");
// }
searchElement(value.trim(), 'name');
}

void searchElement(value,numbers){
try{
final dataa= filterData.where((row) {
final names=row[numbers].toLowerCase();
final inputs=value.toLowerCase();
return names.contains(inputs);
}
).toList();
setState(() {
isSearch=false ;
dataList=dataa;
});
}catch(e){
log(e.toString());
}
}

void sortListASCName(){
filterData.sort((a, b) => a["name"].toString().toLowerCase().compareTo(b["name"].toString().toLowerCase()));
setState(() {
dataList=filterData;
});
}

void sortByDate(){
filterData.sort((a, b) => a["timeStamp"].toString().toLowerCase().compareTo(b["timeStamp"].toString().toLowerCase()));
setState(() {
dataList=filterData;
});
}

void sortByLeads(){
filterData.sort((a, b) => a["leadId"].toString().toLowerCase().compareTo(b["leadId"].toString().toLowerCase()));
setState(() {
dataList=filterData;
});
}

Widget searchBar(){
  return Container(
  padding: const EdgeInsets.only(top: 20.0),
    child: TextField(
controller: inputText,
    onChanged:isDataExist ,
    decoration:  const InputDecoration(hintText: 'Search by name',
border: InputBorder.none,enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
focusedBorder: OutlineInputBorder(
borderSide: BorderSide(width: 3, color: Colors.white),
),
),),
  );
}

Widget statusIcons(){
  if(widget.status=='close'){
  return Icon(Icons.close_rounded,color: mColor,size: 20,);
}else if(widget.status=='open'){
return Icon(Icons.more_horiz,color: mColor,size: 20);
}else if(widget.status=='deal won'){
return Icon(Icons.six_ft_apart_sharp,color: mColor,size: 20);
}else if(widget.status=='followup'){
return Icon(Icons.follow_the_signs,color:mColor,size: 20);
}else if(widget.status=='working'){
return Icon(Icons.business_outlined,color: mColor,size: 20);
}else if(widget.status=='opens'){
return Icon(Icons.open_in_browser,color:mColor,size: 20);
}else if(widget.status=='opens'){
return Icon(Icons.open_in_browser,color: mColor,size: 20);
}else{
return Icon(Icons.error,color: mColor,size: 20);
}
}

bool isSearch=true;


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
foregroundColor:mColor,
title: const Text('My Leads',),
//isSearch? const Text('My Leads',):searchBar(),
centerTitle: true,
actions: [
//   IconButton(onPressed: (){
// setState(() {
// isSearch=!isSearch;
// });
// if(isSearch){
//   dataList=filterData;
// log(isSearch.toString());
//
// }
// }, icon:isSearch? const Icon(Icons.search): const Icon(Icons.close)),
SizedBox(width:80,child: logo),
const SizedBox(width: 10,)

],
),
body:errorLoadSource? Column(
mainAxisAlignment: MainAxisAlignment.center,
  children: [
        NoNetworks.noConnection(context, msg, msg1),
ElevatedButton(onPressed: (){
setState(() {
isLoading=false;
loadError=true;
errorLoadSource=false;
});
_firstLoad();
}, child: Text('try again',style: TextStyle(color: mColor),),),
  ],
): _isFirstLoadRunning
? Center(
child: CircularProgressIndicator(strokeWidth: 2,color: mColor,),
):loadError? Column(
children: [
  Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
Expanded(
//width:MediaQuery.of(context).size.width*0.75,height: 60,
  child:   Container(height: 40,
decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
margin: const EdgeInsets.only(top: 10,bottom: 4,left: 14.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
      children: [
  Expanded(child: searchBar()) ,
    IconButton(onPressed: (){
    setState(() {
      isSearch=true ;
    });
if(isSearch){
inputText.clear();
dataList=filterData;
log(isSearch.toString());
}}, icon:isSearch?const Icon(Icons.search,size: 24,color: Colors.orange,):const Icon(Icons.close,size:24)),
      ],
    ),
  ),
),

//SizedBox(width: 38,child: Text(checkSearchVar)),
    Stack(alignment: Alignment.bottomCenter,
children: [
SizedBox(
  child:   PopupMenuButton(

  icon: const Icon(Icons.filter_alt_sharp,size: 26,),

  color: Colors.orange,

  position: PopupMenuPosition.under,

  itemBuilder: (context){

  return[

  const PopupMenuItem<int>(

  value: 1,

  child: Text('By Name')),

  const PopupMenuItem<int>(

  value: 2,

  child: Text('By Date')),

  const PopupMenuItem<int>(

  value: 3,

  child: Text('By Lead')),

  ];

  },

  onSelected: (value){

  if(value==1){

  checkSearchVar='Name';

  sortListASCName();

  }else if(value==2){

  checkSearchVar='Date';

  sortByDate();

  }else if(value==3){

  checkSearchVar='Lead';

  sortByLeads();

  }

  },

  ),
),
SizedBox(width: 38,child: Text(checkSearchVar,textAlign: TextAlign.center,style: const TextStyle(fontSize: 12),)),
],
)
    ],
  ),
Divider(),
Expanded(
child:  Container(
padding: const EdgeInsets.symmetric(horizontal: 10),
width: double.infinity,
height: double.infinity,
child:jsonDataList.toString()!='[null]'? ListView.builder(
controller: _controller,
itemCount: dataList.length,
itemBuilder: (context,index){
return GestureDetector(
onTap: (){
Navigator.push(context, MaterialPageRoute(builder: (context)=>LeadsDetails(leadId: dataList[index]['leadId'].toString(), status: dataList[index]['status'].toString(), sourceLead: widget.leadSource,nullSouceName: dataList[index]['sourceLead'].toString(),)));
if (kDebugMode) {
  print(index.toString());
}
},
// child: Text(model.name![index].toString()),
child: Card(
shadowColor: Colors.blue.shade300,
elevation: 4.0,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5.0),
margin: const EdgeInsets.only(bottom: 5),
child: Column(
mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(color: Colors.white70,
padding: const EdgeInsets.symmetric(vertical: 2.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Row(
  children: [
    SizedBox(height: 20,width: 20,
      child: statusIcons()),
    Text(' ${dataList[index]['status'].toString()}',style:  TextStyle(color:mColor,fontSize: 14,fontWeight: FontWeight.w400,),),
  ],
),const SizedBox(height: 10,),
Expanded(child: Container()), Text(dataList[index]['timeStamp'].toString(),style:  const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,),),
],
),
),const SizedBox(height: 5,),
//Text('Leads No. : ${dataList[index]['leadId'].toString()}',style: const TextStyle(fontSize: 20),),const SizedBox(height: 10,),
Text('Name   : ${dataList[index]['name'].toString()}',style:  TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.blue.shade500),),const SizedBox(height: 12,),
Text('Product : ${dataList[index]['product'].toString()=='' ?"N/A": dataList[index]['product']} ',style:  const TextStyle(fontSize: 16,fontWeight: FontWeight.w400,),),const SizedBox(height: 12,),
Container(height: 40,
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
log(dataList[index]['contact']);

_launchPhone(dataList[index]['contact']);
}, icon: Icon(Icons.call,color: mColor,size: 25,),),const SizedBox(width: 10,),
IconButton(icon: Icon(Icons.sms,color: mColor,size: 25,),
onPressed: ()async {
  Navigator.push(context, MaterialPageRoute(builder: (context)=> SendSms(phoneNumber: dataList[index]['contact'].toString(),)));
//_launchSms(dataList[index]['contact']);
},
),const SizedBox(width: 10,),
IconButton(icon: Icon(Icons.email,color: mColor,size: 25,),
onPressed: ()async {
  Navigator.push(context, MaterialPageRoute(builder: (context)=>const SendEmail()));
//_launchEmail(dataList[index]['email']);
},
),const SizedBox(width: 10,),
GestureDetector(onTap:(){
log('whatsapp');
_launchWhatsapp(dataList[index]['contact']);
log(dataList[index]['contact'].toString());
},
onLongPress: (){
log(dataList[index]['contact'].toString());

},
child: Image.asset('assets/whatsapp240.png',height: 30,width: 30,)),
// SizedBox(width: 1,),
],
),
)
],
),
),
),
);

}): Center(child: Text(noDataFound.toString())),
),

),

// when the _loadMore function is running
if (_isLoadMoreRunning == true)
 Padding(
padding: const EdgeInsets.only(top: 10, bottom: 40),
child: Center(
child: CircularProgressIndicator(strokeWidth: 2,color: mColor,),
),
),
// When nothing else to load
if (_hasNextPage == false)
Container(
margin: const EdgeInsets.symmetric(horizontal: 10.0),
padding: const EdgeInsets.only(top: 5, bottom: 5,),
color: Colors.orange.shade500,
child:  Center(child: Text('You have fetched all of the content : ${dataList.length}',textAlign: TextAlign.center)),
),
],
):jsonDataList.toString()!='[null]' ? const Center(child: Text('Failed to load Data')):const Center(child: Text('No Data Found')),
);
}

}
