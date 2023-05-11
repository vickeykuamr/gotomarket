import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gm/ApiService/BaseUrl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';


class LoginPage1 extends StatefulWidget {
   final alreadyLogin;
  const LoginPage1({Key? key,required this.alreadyLogin}) : super(key: key);

  @override
  State<LoginPage1> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage1> with TickerProviderStateMixin {

  final _key = GlobalKey<FormState>();
  String? captcha;
  String? newCookies;
  final TextEditingController _userId = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _captcha = TextEditingController();

  late SharedPreferences sharedPreferences;

  bool errorCaptcha=false;
  bool errorEmailOrPassword=false;
  bool isLogin=false;

  String captchaApi='${BaseUrl.apiBaseUrl}/GetCaptcha';
  String loginApi='${BaseUrl.apiBaseUrl}/userlogin';

  var getCaptcha='Loading...';
  bool isRefreshCaptcha=false;
  bool isHiddenPassword=true;

  String? userEmail;
  String? userPass;
  bool mAlreadyLogin=false;
  String msg='';
  String msg1='';

  void iniSharedPreference()async{
    sharedPreferences=await SharedPreferences.getInstance();
    try{
    if(mAlreadyLogin) {
      userEmail=sharedPreferences.getString('userEmail');
      userPass=sharedPreferences.getString('userPass');
    }else {
      sharedPreferences.clear();
    }
      myCaptcha();
    }catch(e){
    log(e.toString());
    }
  }

  bool loginErrorMsg=false;
int loginCount=0;

  Future<void> myLogin()async {
    log(loginApi.toString());
    errorCaptcha=false;
    if(mAlreadyLogin){
      if(loginCount==2){
        setState(() {
          mAlreadyLogin=false;
        });
      }else{
        loginCount++;
        mLogin();
      }
    }else{
      if(_userId.text.trim().isEmpty){
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Enter User Name')));
      }else if(_password.text.trim().isEmpty){
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Enter Password')));
      }else if(_captcha.text.trim().isEmpty){
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Enter Captcha')));
      }else{
        mLogin();
      }
    }
  }

  void showScaffold(text){
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(text.toString())));
  }

  void mLogin()async{

    log(mAlreadyLogin.toString());
    try{
    setState(() {
    isLogin=true;
    });
    var headers = {
    'Content-Type': 'application/json',
    // 'Cache-Control':'no-cache',
    'Cookie':'$newCookies'
    };
    var request = http.Request('POST', Uri.parse(loginApi));

    if(mAlreadyLogin){
    log(mAlreadyLogin.toString());

    request.body = json.encode(
    {
    "username": userEmail.toString(),
    "password": userPass.toString(),
    "Captcha": getCaptcha.toString()
    }
    );
    }else{
    log(mAlreadyLogin.toString());
    request.body = json.encode(
    {
    "username": _userId.text.trim(),
    "password": _password.text.trim(),
    "Captcha":_captcha.text.trim()
    }
    );
    }

    request.headers.addAll(headers);
    var response = await request.send();
    if (response.statusCode == 200) {
    log("status code  200");
    var myResponse=await response.stream.bytesToString();
    var captchaError= myResponse.startsWith("session::Captcha Not Match-reuest:");
    var captchaError1= myResponse.startsWith("session:$getCaptcha:Captcha Not Match-reuest");

    if(myResponse.startsWith('{"content"')){
    try{
    Map<String, dynamic> jsonData=jsonDecode(myResponse);
    var agentName= jsonData['agentName'].toString();
    if(mAlreadyLogin){
    }else{
      sharedPreferences.setString("userEmail", _userId.text.trim());
      sharedPreferences.setString("userPass", _password.text.trim());
      sharedPreferences.setString("agentName",agentName);
      sharedPreferences.setString("userId", "user001");
    }
    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=>const LeadCounterPage()));
    }catch(e){
    if (kDebugMode) {
      print(e);
    }
    showScaffold("Failed to login try again...");
//    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something Wrong Try Again...')));
    }

    }else if(captchaError || captchaError1){
    setState(() {
    isLogin=false;
    errorCaptcha=true;
    });
    }
    else if(myResponse=='Incorrect email-ID or password'){
      if (kDebugMode) {
        print('object');
      }
    setState(() {
    isLogin=false;
    errorEmailOrPassword=true;
    });
    }else{
    isLogin=true;
    showScaffold("Login failed try again...");
//    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed try again...')));
    }
    }
    else {
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print('Captcha Not Matched');
    }

    setState(() {
    isLogin=true;
    errorCaptcha=true;
    });
    showScaffold("Captcha not match");
  //  ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Captcha not match')));

    if (kDebugMode) {
      print(getCaptcha);
    }
    var error=await response.stream.bytesToString();
    if (kDebugMode) {
      print(error);
    }

    var captchaError= error.startsWith("session::Captcha Not Match-reuest:");
    var captchaError1= error.startsWith("session:$getCaptcha:Captcha Not Match-reuest");
    if(captchaError || captchaError1){
    errorCaptcha=true;
    myCaptcha();
    if (kDebugMode) {
      print('Captcha Not Match jjj');
    }
    setState(() {
    isLogin=false;
    });
    if(mAlreadyLogin){
      myCaptcha();
    }
    }else if(error=='Incorrect email-ID or password'){
    setState(() {
    isLogin=false;
    errorEmailOrPassword=true;
    });
    }else{
    setState(() {
    isLogin=false;
    });
    }
    if(mAlreadyLogin){
      myCaptcha();
    }
    }
    }on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Your connection has timed out')));
      //msg="Your connection has timed out";
      // closeDialog();
      isLogin=false;
      loginErrorMsg=false;
      setState(() {
      });
      if (kDebugMode) {
        print("Your connection has timed out");
      }
    }on SocketException catch (_) {

      ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('You are not connected to internet')));
      isLogin=false;
      loginErrorMsg=false;
      log(loginErrorMsg.toString());
      setState(() {
      });
      //msg="You are not connected to internet";
      // closeDialog();
      if (kDebugMode) {
        print("You are not connected to internets");
      }
    }

    catch(e){
    if (kDebugMode) {
      print('Captcha Not Match kk');
    }
    setState(() {
    isLogin=false;
    });

    if(mAlreadyLogin){
      myCaptcha();
    }
    }
  }

  Future<void> myCaptcha()async{
    log('message');
    isRefreshCaptcha=true;
    try{

     var response=await http.get(Uri.parse(captchaApi), headers: {
       "Access-Control-Allow-Origin": "*",
       "Access-Control-Allow-Methods" :"GET, HEAD",
       'Accept': '*/*'

     });

      var cookies=response.headers["set-cookie"];
      if (kDebugMode) {
        print("cookiesssss $cookies");
      }
      final splitCookies = cookies?.split(';');
       newCookies=splitCookies![0];

       log(newCookies.toString());

      sharedPreferences.setString('cookie', newCookies!);

      if(response.statusCode==200){
        var jsonData=jsonDecode(response.body);
        getCaptcha=jsonData['captchastr'];
      }
      isRefreshCaptcha=false;
      if(mAlreadyLogin){
        myLogin();
      }else{
        setState(() {
        });
      }
    }on TimeoutException catch (_) {
      setState(() {
        loginErrorMsg=true;
        isRefreshCaptcha=false;
      });
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('Your connection has timed out')));
      msg="Connection timed out";
     // closeDialog();
      if (kDebugMode) {
        print("Your connection has timed out");
      }
    }on SocketException catch (e) {

      log(e.toString());
      if(e.toString()=='Connection timed out'){
        msg="Connection timed out";
        setState(() {
          isRefreshCaptcha=false;
          loginErrorMsg=true;
        });
      }else if(e.toString()=="Failed host lookup: 'player.go2market.in'" ||e.toString()==''){
        getCaptcha='error';
        msg="You are not connected to internet";
        msg1='Please connect to the internet and try again.';
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor: Colors.orange.shade400,content: const Text('You are not connected to internet')));
        setState(() {
          isRefreshCaptcha=false;
          loginErrorMsg=true;
        });
      }else{
        setState(() {
          isRefreshCaptcha=false;
          loginErrorMsg=true;
        });
      }

      if (kDebugMode) {
        print("You are not connected to internet");
      }
    }
  }

  late AnimationController controller;

  @override
  void initState() {
    mAlreadyLogin=widget.alreadyLogin;
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: false);
    iniSharedPreference();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
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
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);
      },
      child:Scaffold(
        backgroundColor: Colors.white,
        body:mAlreadyLogin? Center(child: CircularProgressIndicator(value: controller.value,strokeWidth: 2,),): SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _key ,
                child: Container(
                  margin: const EdgeInsets.only(left: 20,right: 20,top: 40,bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    //  SvgPicture.asset("assets/goto_logo.svg"),
                      Image.asset('assets/go2marketlogo.png',height: 50,),
                      const SizedBox(
                        height: 40,
                      ),
                      errorEmailOrPassword==true?const Text('Incorrect email-ID or password',style: TextStyle(color: Colors.red,fontSize: 18),):Container(),
                      const SizedBox(
                        height: 20,),
                      Container(
                      //  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextFormField(
                          controller: _userId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person,color: Colors.orange,),
                            border: InputBorder.none,
                            hintText: "User-id",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextFormField(
                          controller: _password,
                          obscureText: isHiddenPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.password,color: Colors.orange,),
                            border: InputBorder.none,
                            suffix: InkWell(onTap: (){
                              setState(() {
                                isHiddenPassword=!isHiddenPassword;
                              });
                             // log(isHiddenPassword.toString());
                            },
                                child:isHiddenPassword?const Icon(Icons.visibility_outlined,color: Colors.blue,) : const Icon(Icons.visibility_off_outlined,color: Colors.blue,)),
                            hintText: "password",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextFormField(
                          controller: _captcha,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.image,color: Colors.orange,),
                            border: InputBorder.none,
                            hintText: "Enter captcha",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      errorCaptcha? Container(margin:const EdgeInsets.only(left: 20.0,bottom: 10),alignment:Alignment.centerLeft,child: const Text('Captcha Not Match',style: TextStyle(color: Colors.red,fontSize: 16),),):Container(),
                    //  const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: size.width*0.50,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                border: Border.all(color: Colors.black)
                            ),
                            child: Text(getCaptcha.toString(), style: TextStyle(
                                fontSize:size.width <200.0?10.0:18.0
                            ),),
                          ),
                          IconButton(onPressed: (){
                            errorCaptcha=false;
                            errorEmailOrPassword=false;
                            setState(() {
                              isRefreshCaptcha=true;
                            });
                            myCaptcha();
                          }, icon:isRefreshCaptcha?const Icon(Icons.circle_outlined,color: Colors.teal,):const Icon(Icons.refresh_sharp)),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      SizedBox(
                        width: size.width,
                        child: ElevatedButton(onPressed: (){
                          errorEmailOrPassword=false;
                          errorCaptcha=false;
                          myLogin();
                        },
                            style: ElevatedButton.styleFrom(
                              //  padding: const EdgeInsets.symmetric(),
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                )
                            ),
                          child:isLogin? Center(
                            child: SizedBox(height: 20,width: 20,
                                child: CircularProgressIndicator(color: Colors.orange.shade200,strokeWidth: 1,)),
                          ):const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ) ,
      ),
    );
  }
}