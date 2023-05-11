import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gm/NetworkPage/NoNetwork.dart';
import 'package:gm/SessionPage/MySession.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ApiService/BaseUrl.dart';
import '../HomePage.dart';
import 'PagingCardPage.dart';

class LeadStatus extends StatefulWidget {
  final logo;
  final leadSource;
  final nullCount;
  const LeadStatus({Key? key,required this.leadSource, this.nullCount, this.logo}) : super(key: key);

  @override
  State<LeadStatus> createState() => _ListKaraState();
}

class _ListKaraState extends State<LeadStatus> {

  late SharedPreferences sharedPreferences;

  var leadStatusApiUrl='${BaseUrl.apiBaseUrl}/LeadStatusCounter?sourceLead=';
  var myLeadCountList=[];
  var myLeadStatus=[];
  late List<dynamic> leadLength=[];
  var getCookies;
  bool isLoading=false;
  bool loadError=true;
  String msg='';
  String msg1='';
  bool  errorLoadSource=false;

  Future<void> getLeadStatus()async{
print(widget.leadSource);

    try{
      var headers = {
        'Content-Type': 'application/json',
        'Cookie':'$getCookies',
      //  'Cache-Control':'no-cache'
      };

      var request = http.Request('GET', Uri.parse(leadStatusApiUrl+widget.leadSource));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        myLeadStatus.clear();
        myLeadCountList.clear();
        leadLength.clear();
        var res= await response.stream.bytesToString();
        var jsonData=jsonDecode(res);
        print(jsonData);
        var jsonData1=jsonData['content'];
        leadLength=jsonData1;

        for(int i=0; i<leadLength.length;i++){
          var chechNull=jsonData1[i]['status'];
          log('kjdshfdjdsjfhbdj ${chechNull.toString()}');
          if(widget.leadSource=='walkinn'){
            if(chechNull=='openn'){
              var storeNull= jsonData1[i]['count'];
              var total =int.tryParse(storeNull)! + widget.nullCount;
              log(total.toString());
              myLeadCountList.add(total);
              myLeadStatus.add(jsonData1[i]['status']);
              log("kjhjgjhgjhgjgjh");
            }else{
              myLeadCountList.add(jsonData1[i]['count']);
              myLeadStatus.add(jsonData1[i]['status']);
            }
          }else{
            myLeadCountList.add(jsonData1[i]['count']);
            myLeadStatus.add(jsonData1[i]['status']);
          }
        }
        log('dgfgdfgfgr ${myLeadCountList[0]}');
        setState(() {
          isLoading=true;
        });
      }
      else {
        print(response.reasonPhrase);
        if(response.reasonPhrase=='Unauthorized'){
    MySessions.sessionExpire(context);
        }else{
          loadError=false;
          isLoading=false;
        }
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
      print("Your connection has Timed Out");
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
  }


  Future<void> getSharedPreference()async{
    sharedPreferences=await SharedPreferences.getInstance();
    getCookies= sharedPreferences.getString('cookie');
    log(widget.nullCount.toString());
    getLeadStatus();
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor:mColor,
          title: Text('${widget.leadSource}',),
          actions: [
            SizedBox(width: 80,
                child: logo),
            const SizedBox(width: 20,)
          ],
          centerTitle: true,
        ),
        body: errorLoadSource? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NoNetworks.noConnection(context, msg, msg1),
            ElevatedButton(onPressed: (){
              setState(() {
                isLoading=false;
                loadError=true;
               errorLoadSource=false;
              });
              getLeadStatus();
            }, child: Text('try again',style: TextStyle(color: mColor),),),

          ],
        ):
        isLoading? Container (
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child:myLeadCountList[0].toString()!='null'? ListView.builder(
                itemCount: leadLength.length,
                itemBuilder: (context, index){
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PagingLeadsCard(leadSource: widget.leadSource, status: myLeadStatus[index],)));
                    },
                    child: Card(
                      elevation: 2,
                      color: Colors.white,shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),borderRadius: BorderRadius.circular(7)),
                      child: ListTile(
                        title: Text(myLeadStatus[index].toString()),
                        trailing: Text('[ ${myLeadCountList[index]} ]'),
                      ),
                    ),
                  );
                }):const Center(child: Text('No Lead Found')),

        ):loadError? Center(child: CircularProgressIndicator(strokeWidth: 2,color: mColor,),):const Center(child: Text('Failed to Load Leads')),
    );
  }
}
