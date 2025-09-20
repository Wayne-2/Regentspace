import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newregentspace/core/utils/auth_page/createaccount.dart';
import 'package:newregentspace/core/utils/components/button.dart';
import 'package:newregentspace/core/utils/components/inputarea.dart';
import 'package:newregentspace/core/utils/components/text.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
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
      body:Stack(
        children: [
          Positioned(
            right:-64,
            top: -25,
            child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/logo.png')),
                  ),
                  width: 117,
                  height: 252,
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color:Color.fromRGBO(108, 0, 144, 1),
                        borderRadius: BorderRadius.circular(34)
                      ),
                      child:Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 28,)),),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment:CrossAxisAlignment.end,
                            children:[
                              Text('RegentSpace', style: TextStyle(height:1.3,fontSize: 32, fontWeight: FontWeight.bold, color: Color.fromRGBO(46, 3, 66, 1)),),
                              Text('Technologies', style: TextStyle(height:1.3, fontSize: 24, fontWeight: FontWeight.w400, color: Color.fromRGBO(46, 3, 66, 1)),),
                            ]
                          ),
                          SizedBox(width: 33,)
                        ],
                      )
                  ]
                ),
                SizedBox(height: 20,),
                Textlarge(text: 'Login'),
                SizedBox(height: 10,),
                Textmedium(text:'Welcome back!' ),
                Textmedium(text:'Please login to continue' ),
                SizedBox(height: 20,),
                Inputarea(prefixicon: 'assets/icons/Mail.svg', label: 'Email Address', placeholder: 'Your email address', suffixicon: '', obscuretext: false),
                SizedBox(height: 8,),
                Inputarea(prefixicon: 'assets/icons/Lock.svg', label: 'Password', placeholder: 'Enter your password', suffixicon: 'assets/icons/Eye.svg', obscuretext: true),
                SizedBox(height: 20,),
                Button(label: 'Login'),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Forgot password?', style: TextStyle(color: Color.fromRGBO(133, 99, 188, 1), fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 35,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Textmedium(text:"Don't have account?" ),
                    SizedBox(width: 3,),
                     GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Createaccountpage()));
                      },
                      child: Text('Create Now', style: TextStyle(color: Color.fromRGBO(133, 99, 188, 1), fontSize: 16, fontWeight: FontWeight.w500))),
                  ],
                ),
              ],),
          ),
        ],
      )
    );

  }
}
