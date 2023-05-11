import 'package:flutter/material.dart';

class NoNetworks{
static  Widget noConnection(BuildContext context,msg, msg1){
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Image.asset('assets/nowifi.png',width: 30,height: 35,),const SizedBox(height: 6,),
          const Icon(Icons.wifi_off_sharp,size: 40,),
          const SizedBox(height: 6,),

          Text(msg.toString(),style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 18),),const SizedBox(height: 6,),
          Text(msg1.toString(),style: const TextStyle(fontWeight: FontWeight.w500),),const SizedBox(height: 6,),

        ],
      ),
    );
}
}

// ElevatedButton(onPressed: (){
// // setState(() {
// // errorLoadSource=false;
// // });
// leadStatus();
// }, child: const Text('Try Again',style: TextStyle(color: Colors.white),),),
//