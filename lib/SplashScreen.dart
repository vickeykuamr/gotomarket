import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'LoginPages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var userId='';
  SharedPreferences? sharedPreferences;

  share(){
    userId=sharedPreferences!.getString("userId").toString();
    log(userId.toString());
    if(userId.toString()=='user001'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LeadCounterPage()));
     // Navigator.popUntil(context, (route) => route.isFirst);
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginPage1(alreadyLogin: false,)));
    }
  }
  
  void startSplashScreen(){
  Timer(const Duration(seconds: 2),() async {
    sharedPreferences= await SharedPreferences.getInstance();
    share();
  });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
    startSplashScreen();
  }
@override
  void dispose() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);

  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      body: Center(child: Image.asset("assets/go2marketlogo.png",height: 60,)),
    );
  }
}
