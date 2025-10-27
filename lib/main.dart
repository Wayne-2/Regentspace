import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:newregentspace/core/utils/auth_page/createaccount.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home:Loadingpage()
  ));
}

class Loadingpage extends StatefulWidget {
  const Loadingpage({super.key});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage> {
  
  @override
  void initState() {
  super.initState();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    )
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  Future.delayed(Duration(seconds: 8), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> Createaccountpage()));
    });
  }
  
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/logo.png')),
                    ),
                    width: 134,
                    height: 288,
                  ),
                  SizedBox(height:50),
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(65, 0, 86, 1),
                    ),
                  ),
                  Text(
                    'Are you ready to take off?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(65, 0, 86, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        size: 50, 
                        color:Color.fromRGBO(209, 69, 255, 1),
                      ),),
                  )
                ],),
            ),
          ],
        ),
      )
    );

  }
}
