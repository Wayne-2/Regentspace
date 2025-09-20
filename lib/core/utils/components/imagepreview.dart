import 'package:flutter/material.dart';

class Imagepreview extends StatelessWidget {
  const Imagepreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
              width: MediaQuery.of(context).size.width*1.0,
              height: 266,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                color: Color.fromRGBO(175, 175, 175, 1),
                 width: 1.0,
              )),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Text('Preview pages here', style: TextStyle(fontSize: 15, color: Color.fromRGBO(0, 0, 0, 0.3), fontWeight: FontWeight.w300)),
                      SizedBox(width: 10,),
                       Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage('assets/addLogo.png')),
                          ),
                          width: 67,
                          height: 144,
                        ),
                      SizedBox(width: 10,),
                      Text('App logo', style: TextStyle(fontSize: 15, color: Color.fromRGBO(0, 0, 0, 0.3), fontWeight: FontWeight.w300))
                  ]
                ),
              ),
            ),
    );
  }
}
class Editorarea extends StatelessWidget {
  const Editorarea({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
              width: MediaQuery.of(context).size.width*1.0,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                color: Color.fromRGBO(175, 175, 175, 1),
                 width: 1.0,
              )),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.arrow_back, size: 17, color: Colors.black),
                        Text('Background', style: TextStyle(fontSize: 16, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.w600)),
                        Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color:Color.fromRGBO(162, 162, 162, 1),
                              borderRadius: BorderRadius.circular(34)
                            ),
                            child:Center(child: Icon(Icons.check, color: Colors.white, size: 15,)),),
                      ],
                    ),
                    SizedBox(height: 10,),
                     Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Color', style: TextStyle(fontSize: 15, color: Color.fromRGBO(0, 0, 0, 0.71), fontWeight: FontWeight.w600)),
                       ],
                     ),
                    SizedBox(
                    width:324,
                    height: 50,
                     child: ListView(
                      scrollDirection:Axis.horizontal,
                      children:[
                        Colorinput(colorcode: Colors.red),
                        Colorinput(colorcode: Colors.blue),
                        Colorinput(colorcode: Colors.purple),
                        Colorinput(colorcode: Colors.yellow),
                        Colorinput(colorcode: Colors.green),
                        Colorinput(colorcode: Colors.pink),
                        Colorinput(colorcode: Colors.orange),
                      ]
                     ),
                   )
                ]
              ),
            ),
    );
  }
}

class Colorinput extends StatelessWidget {
  const Colorinput({super.key, required this.colorcode});
  final Color colorcode;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: CircleAvatar(
        backgroundColor: colorcode,
        radius: 17,
      ),
    );
  }
}