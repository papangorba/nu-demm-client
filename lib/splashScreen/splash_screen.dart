import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pndtech_client/authentification/connexion_page.dart';
import 'package:pndtech_client/authentification/register_screen.dart';
import 'package:pndtech_client/pages/home_page.dart';
import 'package:pndtech_client/splashScreen/splash_screen1.dart';
import 'package:pndtech_client/theme/theme.dart';


import '../global/global.dart';
import '../mainScreen/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const   MySplashScreen({Key? Key}) : super(key: Key);


  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}
class _MySplashScreenState extends State<MySplashScreen>{
  startTimer(){
    Timer(const Duration(seconds: 3), () async {
      if(await fAuth.currentUser != null){
        Navigator.push(context, MaterialPageRoute(builder: (c)=>HomePage()  ));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ConnexionPage()));
      }

    });
  }
  @override
  void initState(){
    super.initState();
    
    startTimer();
  }
  Widget build(BuildContext context){
    return Material(
      child:Container(
        color:Color(0xFF452778),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/img6.png"),

            ],
          ),
        ),
      ),
    );
  }
}



