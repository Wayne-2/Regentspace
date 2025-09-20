
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newregentspace/core/utils/auth_page/loadingscreen.dart';
import 'package:newregentspace/core/utils/components/button.dart';
import 'package:newregentspace/core/utils/components/minitextfield.dart';
import 'package:newregentspace/core/utils/components/text.dart';

class Verificationpage extends StatefulWidget {
  const Verificationpage({super.key});

  @override
  State<Verificationpage> createState() => _VerificationpageState();
}

class _VerificationpageState extends State<Verificationpage> {
  @override
  void initState() {
  super.initState();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white
    ));}

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {},
          child: Icon(Icons.arrow_back_ios_sharp)),
        title: Text('Verify account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),) ,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:25.0, vertical: 10),
        child: Column(
          children: [
            Textmedium(text:'To verify account please enter OTP in the field below. Enter the 5 digit OTP sent via email to you below to proceed.' ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Minitextfield(),
                  SizedBox(width: 20,),
                  Minitextfield(),
                  SizedBox(width: 20,),
                  Minitextfield(),
                  SizedBox(width: 20,),
                  Minitextfield(),
                ]
              ),
            ),
            SizedBox(height: 20,),
           
              GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Loadingscreen()));
                    },
                    child:  Button( label: 'verify',),),
              SizedBox(height: 10,),
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Textmedium(text:"Didn't recieve OTP?" ),
                      SizedBox(width: 3,),
                      GestureDetector(
                        onTap: (){
                          // Logic to resend OTP
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(
                                  child: Text(
                                    'OTP resent!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        child: Text('Resend', style: TextStyle(color: Color.fromRGBO(133, 99, 188, 1), fontSize: 16, fontWeight: FontWeight.w500))),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}