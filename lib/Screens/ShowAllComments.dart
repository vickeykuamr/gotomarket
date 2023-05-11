import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gm/HomePage.dart';

class ShowAllComments extends StatefulWidget {
  final comments;
  const ShowAllComments({Key? key,required this.comments}) : super(key: key);

  @override
  State<ShowAllComments> createState() => _ShowAllCommentsState();
}

class _ShowAllCommentsState extends State<ShowAllComments> {

  List colors=[Colors.orange,Colors.blueGrey,Colors.blue,Colors.red,Colors.green,Colors.greenAccent,Colors.indigo,Colors.purple,Colors.cyan.shade300,Colors.green.shade400,Colors.purple.shade400,Colors.lightBlue.shade300,Colors.deepPurpleAccent.shade400,Colors.purple.shade300];

  var showMsg=TextOverflow.ellipsis;
  var ind=0;
  int commentLength=0;
  List<dynamic> commentData=[];

  void comments(){
    if(widget.comments!=null){
      try{
         commentData=widget.comments;
        commentLength=commentData.length;
        //log(leadDetailModel.comment.toString());
        log(commentLength.toString());
        setState(() {});
      }catch(e){
       // print(leadDetailModel.comment);
        log('fgfgdf  $e');
      }
      log('kkkkkkk');
    }
  }

  @override
  void initState() {
    super.initState();
    comments();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Comments'),centerTitle: true,foregroundColor:mColor,
      actions: [
        Container(margin: const EdgeInsets.only(right: 10),
            width:80,height: 80,child: logo)
      ],),
      body:(commentLength>0) ? Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 10.0),
        padding: const EdgeInsets.only(top: 8.0,left: 8.0),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
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
        child:SizedBox(
          //height: 200,
          child: ListView.builder(itemCount: commentLength,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  Column(
                    children: [
                      Container(height: 40,width:40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0),color:index<=14?colors[index]:Colors.lightBlueAccent.shade400,),
                        child: Center(child:Text('${commentData[index]['firtName']}',style: const TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),)),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${commentData[index]['agentName']}',style: const TextStyle(color: Colors.blue),),
                             // const SizedBox(width: 4,),
                              Text(' , ${commentData[index]['timeStamp']}',style: const TextStyle(),),
                            ],),
                          InkWell(onTap: (){
                            setState(() {
                              ind=index;
                              showMsg=TextOverflow.visible;
                            });
                          },
                              child: Text('${commentData[index]['comment']}',
                                  style: const TextStyle(fontSize: 14),overflow:index==ind? showMsg:TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.orange,),
                ],);
            },
          ),
        ),
      ) :Container(
          padding: const EdgeInsets.all(10.0),
          child: const Center(child: Text('No Comment'))),
    );
  }
}
