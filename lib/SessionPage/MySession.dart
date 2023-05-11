import 'dart:developer';
import 'package:flutter/material.dart';
import '../LoginPages.dart';

class MySessions{
 static void sessionExpire(BuildContext context){

    //
    //
    // showDialog(barrierDismissible: false,
    //     context: context, builder: (BuildContext ctx){
    //       return const AlertDialog(
    //         title: Text('Session Expired'),
    //         // actions: [
    //         //   TextButton(onPressed: (){
    //         //     // sharedPreferences.clear();
    //         //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LoginPage1(alreadyLogin: true,)), (route) => false);
    //         //   }, child: const Text('Login again')),
    //         //   TextButton(onPressed: (){
    //         //      //sharedPreferences.clear();
    //         //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LoginPage1(alreadyLogin: false,)), (route) => false);
    //         //   }, child: const Text('Log Out')),
    //         // ],
    //       );
    //     });
    // log('expire');

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LoginPage1(alreadyLogin: true,)), (route) => false);
ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Session Expired Please Wait...')));
 }

}