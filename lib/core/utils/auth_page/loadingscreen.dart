import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:newregentspace/core/network/navigator.dart';


class Loadingscreen extends StatefulWidget {
  const Loadingscreen({super.key});

  @override
  State<Loadingscreen> createState() => _LoadingscreenState();
}

class _LoadingscreenState extends State<Loadingscreen> {
  
  @override
  void initState() {
  super.initState();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white
    )
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  Future.delayed(Duration(seconds: 10), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> RegentBottomNav()));
    });
  }
  
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SizedBox(
        width:MediaQuery.of(context).size.width*1.0,
        child: Stack(
          children: [
            Positioned(
              right:-402,
              top: -508,
              child: Container(
                    decoration: BoxDecoration(
                     color: Color.fromRGBO(240, 83, 240, 0.28),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    width: 804,
                    height: 743,
                  ),
            ),
            Positioned(
              right:-639,
              top: -238,
              child: Container(
                    decoration: BoxDecoration(
                     color: Color.fromRGBO(240, 83, 240, 0.28),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    width: 804,
                    height: 743,
                  ),
            ),
            Positioned(
              left:-508,
              bottom: -445,
              child: Container(
                    decoration: BoxDecoration(
                     color: Color.fromRGBO(240, 83, 240, 0.28),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    width: 804,
                    height: 743,
                  ),
            ),
            Positioned(
              left:-555,
              bottom: -445,
              child: Container(
                    decoration: BoxDecoration(
                     color: Color.fromRGBO(240, 83, 240, 0.28),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    width: 804,
                    height: 743,
                  ),
            ),
            Positioned(
              left:-617,
              bottom: -445,
              child: Container(
                    decoration: BoxDecoration(
                     color: Color.fromRGBO(240, 83, 240, 0.28),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    width: 804,
                    height: 743,
                  ),
            ),
            SizedBox(
              width:MediaQuery.of(context).size.width*1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
               Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        size: 80, 
                        color:Color.fromRGBO(209, 69, 255, 1),
                      ),),
                  ),
                  SizedBox(height: 20,),
                 
                  Text(
                    'Getting started...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(65, 0, 86, 1),
                    ),
                  ),
                  
                ],),
            ),
          ],
        ),
      )
    );

  }
}
