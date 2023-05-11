import 'package:flutter/material.dart';
import 'package:gm/HomePage.dart';

class ViewActivityPAge extends StatefulWidget {
  final event;
   const ViewActivityPAge({Key? key,required this.event}) : super(key: key);

  @override
  State<ViewActivityPAge> createState() => _ViewActivityPAgeState();
}

class _ViewActivityPAgeState extends State<ViewActivityPAge> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(foregroundColor: mColor,
        title: const Text('Activity'),centerTitle: true,
      actions: [Container(width: 80,height: 80,
          margin: const EdgeInsets.only(right: 10.0),
          child: logo)],),
      body: SafeArea(
        child:widget.event!=null? Container(
          width: double.infinity,
          height: 174,
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agent Name : ${widget.event[0]['agentName']}',style: const TextStyle(fontSize: 16),),const SizedBox(height: 10,),
              Text('Assigned To     : ${widget.event[0]['assignedTo']}'),const SizedBox(height: 10,),
              Text('Activity Type    : ${widget.event[0]['activityType']}'),const SizedBox(height: 10,),
              Text('Subject             : ${widget.event[0]['subject']}'),const SizedBox(height: 10,),
              Row(
                children: [
                  Text('From Time       : ${widget.event[0]['fromTime']} ,'),const SizedBox(width: 10,),
                  Text('Date : ${widget.event[0]['date'].toString().substring(0,10)}'),
                ],
              ),const SizedBox(height: 10,),
              Row(
                children: [
                  Text('To Time            : ${widget.event[0]['toTime']} ,'),const SizedBox(width: 10,),
                  Text('To Date : ${widget.event[0]['toDate']}'),
                ],
              ),
            ],
          ),
        ):const Center(child: Text('No Activity Found')),
      ),

    );
  }
}
