import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logopage extends StatefulWidget {
  const Logopage({super.key});

  @override
  State<Logopage> createState() => _LogopageState();
}

class _LogopageState extends State<Logopage> {
  final _textEditingController = TextEditingController();
  String appName = 'Input app name';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70,
                  child: Text('App Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: 
                    Container(
                      height: 47,
                      color:const Color.fromRGBO(245, 245, 245, 1),
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(onPressed: (){
                            _textEditingController.clear();
                          }, icon: Icon(Icons.clear)),
                          hintText: ''),
                        style: GoogleFonts.lato(fontSize: 14),
                      ),
                    ),
                  
                ),
                SizedBox(width: 8,),
                MaterialButton(
                  onPressed: (){
                    setState(() {
                      appName = _textEditingController.text;
                    });
                  },
                  color: Color.fromRGBO(108, 0, 144, 1),
                  child: Text('add', style: TextStyle(color: Colors.white, fontSize: 14)),
                )
              ],
            ),
    );
  }
}