import 'package:flutter/material.dart';
import 'package:gm/HomePage.dart';

var activityList=['Call', 'E-mail', 'Online Demo', 'Online Meeting', 'Meeting', 'Others'];
var activityValue;

DateTime selectedDate = DateTime.now();
TimeOfDay pickedTime =TimeOfDay.now();

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101));
  if (picked != null && picked != selectedDate) {
    selectedDate = picked;
  }
}

Future<void> _selectTime(BuildContext context)async{
  TimeOfDay initialTime = TimeOfDay.now();
  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );
  pickedTime=pickedTime!;
}

Future<void> addEvent(context)async{

}

 Future showAddEventWidgets(BuildContext context)async {
  showDialog(barrierDismissible: false,
      context: context, builder: (BuildContext ctx){
    return StatefulBuilder(
        builder: (ctx,setState){
          return Dialog(
            // var width=MediaQuery.of(context).size.width;
              child: SingleChildScrollView(
                child: Container(
                  //  width: double.infinity,
                  height: 420,
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
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Container(width: double.infinity,
                          color: Colors.orange,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text('Quick Create Event',textAlign: TextAlign.center,style: TextStyle(fontSize: 18),)),
                      const SizedBox(height: 10,),
                      const Text('Subject :',style: TextStyle(fontSize: 16),),const SizedBox(height: 10,),
                        const TextField(decoration: InputDecoration(hintText: "Enter Subject",enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),border: OutlineInputBorder(borderRadius:BorderRadius.horizontal())),),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              const Text('From Date'),const SizedBox(height: 10,),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(borderRadius: const BorderRadius.horizontal(),border:Border.all(color:Colors.orange)),
                                child: InkWell(
                                    onTap: (){
                                      _selectDate(context).then((value) {
                                        // log(value.toString());
                                        setState(() {});
                                      }
                                      );
                                    },
                                    child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')),
                              )
                            ],
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              const Text('Time'),const SizedBox(height: 10,),
                              Container(width: 90,
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(borderRadius: const BorderRadius.horizontal(),border:Border.all(color: Colors.orange)),
                                child: InkWell(
                                    onTap: (){
                                      _selectTime(context).then((val){
                                        setState(() {});
                                      });
                                    },
                                    child: Text('${pickedTime.hour}:${pickedTime.minute}')),
                              )
                            ],
                          ),
                        ],
                      ),const SizedBox(height: 20,),
                      const Text('Activity Type :'),const SizedBox(height: 10,),
                      Container(width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(borderRadius: const BorderRadius.horizontal(),border: Border.all(color: Colors.orange)),
                        //  width: 2,
                        padding: const EdgeInsets.only(left: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            hint:const Text('--Select Activity--'),
                            items: activityList
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
                            value: activityValue,
                            onChanged: (value) {
                              setState(() {
                                activityValue = value as String;
                              });
                            },

                          ),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(onPressed: (){
                            addEvent(context).then((value) {
                            });
                          }, child: Text('Save',style: TextStyle(color: mColor),)),
                          ElevatedButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text('Cancel',style: TextStyle(color:mColor))),
                        ],
                      ),
                    ],
                  ),),
              ));
        });
  });
}