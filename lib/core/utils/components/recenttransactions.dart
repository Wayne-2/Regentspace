import 'package:flutter/cupertino.dart';

class Recenttransactions extends StatelessWidget {
  const Recenttransactions({super.key, required this.imageplaceholder,required this.placeholdercolor,required this.placeholdertextcolor, required this.username, required this.usernameactivity, required this.date});
  final String imageplaceholder;
  final Color placeholdercolor;
  final Color placeholdertextcolor;
  final String username;
  final String usernameactivity;
  final String date;
  @override
  Widget build(BuildContext context) {
    return Row(
             children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  color: placeholdercolor
                ),
                child: Center(
                  child: Text(imageplaceholder, style:TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: placeholdertextcolor
                  )),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color.fromRGBO(0, 0, 0, 1),)),
                        Text(usernameactivity, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: const Color.fromRGBO(0, 0, 0, 0.54)),),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(date, style: TextStyle(fontWeight: FontWeight.w300, color: const Color.fromARGB(255, 0, 0, 0), fontSize: 11),), 
                        Text("Successful", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color.fromRGBO(13, 146, 29, 1)),),
                      ],
                    ),
                  ],
                ),
              ),
             ]);
  }
}