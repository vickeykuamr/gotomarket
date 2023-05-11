import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gm/ApiService/BaseUrl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchElemenmt extends StatefulWidget {
  const SearchElemenmt({Key? key}) : super(key: key);

  @override
  State<SearchElemenmt> createState() => _SearchElemenmtState();
}

class _SearchElemenmtState extends State<SearchElemenmt> {

  var jsonDataList=[];

  var data;


  List rows = [
    {"ags": "01224", "name": "Test-1"},
    {"ags": "01224", "name": "Test-1"},
    {"ags": "22222", "name": "Test-2"},
  ];

  late List<dynamic> hh;

  bool isSearch=false;
  void isDataExist(String value) {
    log("dcfdfdf "+value.toString());

   // final number = num.tryParse(value);

    if(value.startsWith('0') ||value.startsWith('1') ||value.startsWith('2') ||value.startsWith('3') ||value.startsWith('4')
    ||value.startsWith('5')||value.startsWith('6')||value.startsWith('7') ||value.startsWith('8')||value.startsWith('9')){
      log('dfdfdgfd');
      searchElement(value, "leadId");
    }else{
      searchElement(value, 'name');
    }
    // switch(number){
    // case 0:searchElement(number,"leadId");
    // break;  case 1:searchElement(number,"leadId");
    // break;  case 2:searchElement(number,"leadId");
    // break;  case 3:searchElement(number,"leadId");
    // break;  case 4:searchElement(number,"leadId");
    // break;  case 5:searchElement(number,"leadId");
    // break;  case 6:searchElement(number,"leadId");
    // break;  case 7:searchElement(number,"leadId");
    // break;  case 8:searchElement(number,"leadId");
    // break;  case 9:searchElement(number,"leadId");
    // break;
    //   default:{
    //     if(isSearch){
    //
    //     }else{
    //
    //     }
    //     searchElement(value,"name");
    //   }
    //   break;
    // }

  }

  void searchElement(value,numbers){
    try{
      final dataa= hh.where((row) {
log(row['leadId'].toString());
        final names=row[numbers].toLowerCase();
        final inputs=value.toLowerCase();
        return names.contains(inputs);
      }
      ).toList();
      setState(() {
        data=dataa;
        log(dataa.toString());
      });
    }catch(e){
      log(e.toString());
    }

  }
  void searchBox(String query){

    final number = num.tryParse(query);
switch(number){
  case 0:log(number.toString());
    break;
  case 1:log(number.toString());
  break;  case 2:log(number.toString());
break;  case 3:log(number.toString());
break;  case 4:log(number.toString());
break;  case 5:log(number.toString());
break;  case 6:log(number.toString());
break;  case 7:log(number.toString());
break;  case 8:log(number.toString());
break;  case 9:log(number.toString());
break;
}
  }

  var getCookies;

  late SharedPreferences sharedPreferences;

  Future<void> getSharedPreference()async{
    try{
      sharedPreferences=await SharedPreferences.getInstance();
      getCookies= sharedPreferences.getString('cookie');
// agentPage= sharedPreferences.getString('pageNumber');
// agentSize= sharedPreferences.getString('size');
      print("kkkkk $getCookies");
      _firstLoad();
    }catch(e){}
  }
  
  
  
  void sortListName(){
    hh.sort((a, b) => a["name"].toLowerCase().compareTo(b["name"].toLowerCase()));
    setState(() {
      data=hh;
    });
    print(hh);

  }
  void dates(){
    hh.sort((a, b) => a["timeStamp"].toLowerCase().compareTo(b["timeStamp"].toLowerCase()));
    setState(() {
      data=hh;
    });
    print(hh);

BaseUrl.apiBaseUrl;
  }


  void _firstLoad() async {

    log(BaseUrl.apiBaseUrl.toString());

    try{
      var headers = {
        'Content-Type': 'application/json',
        'Cookie':'$getCookies',
//'Cache-Control':'no-cache'
      };
      var request = http.Request('GET', Uri.parse('${BaseUrl.apiBaseUrl}/leadDetail?sourceLead=google&status=followup&pageNumber=1&size=30'));
      log(request.toString());
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res= await response.stream.bytesToString();
        var jsonData=jsonDecode(res);
      jsonDataList.add(jsonData['content']);
      data=jsonDataList[0];

      log(data.toString());

      hh=data;


//         try{
//           int k=0;
//           while(k<jsonDataList.length){
//             for(int i=0;i<jsonDataList[_page-1].length;i++){
//               dataList.add(jsonDataList[_page-1][i]);
//               k++;
//             }
//           }
//
//
// //log(dataList.toString());
//         }catch(e){
//
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('Failed to load data Try again',style: TextStyle(color: Colors.amber),))));
//         }

      }
      else {
        print(response.reasonPhrase);
        if(response.reasonPhrase=='Unauthorized'){
         // sessionExpired();
        }
        setState(() {

        });
      }
    }catch(e){
      print("gggggggggg"+e.toString());
      setState(() {

      });
    }

    setState(() {
    //  _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    getSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("kk"),

        actions: [
          PopupMenuButton(
            icon: Icon(Icons.filter_alt_sharp),
            color: Colors.white,
            position: PopupMenuPosition.under,
            itemBuilder: (context){
              return[
                const PopupMenuItem<int>(
                    value: 1,
                    child: Text('sort name')),
                const PopupMenuItem<int>(
                    value: 2,
                    child: Text('date')),
              ];
            },
            onSelected: (value){
              if(value==1){
                sortListName();
              }else if(value==2){
                dates();
             //   Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchElemenmt()));
              }
            },
          )

        ],
      ),
      body: Column(
        children: [

          TextField(
            onChanged: isDataExist,
          ),

          Expanded(
              child: ListView.builder(
                itemCount: data.length,
                  itemBuilder: (context, index){

                final book=data[index];
                  return Text(book['name'].toString());
              }),
          )

        ],
      ),
    );
  }
}
