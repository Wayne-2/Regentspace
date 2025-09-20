import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newregentspace/core/src/dashboard/dashboard_tools/activeusers.dart';
import 'package:newregentspace/core/src/dashboard/dashboard_tools/newuser.dart';
import 'package:newregentspace/core/src/dashboard/dashboard_tools/updates.dart';
import 'package:newregentspace/core/src/dashboard/dashboard_tools/userreview.dart';
import 'package:newregentspace/core/vtu_template/notificationpage.dart';
import 'package:newregentspace/core/vtu_template/userprofile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  String hiddenamount = 'N 2,554,000.00';
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
                  title: Text(
                  "RegentSpace",
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),    
                ),
                actions:[
                     
                      DropdownButtonHideUnderline(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            icon: Icon(Icons.more_vert, size: 25, color: Colors.black54,),
                            borderRadius: BorderRadius.circular(8),
                            dropdownColor: Colors.white,
                            items: [
                              DropdownMenuItem(
                                value: 'Settings',
                                child: Text('Settings'),
                              ),
                              DropdownMenuItem(
                                value: 'Info',
                                child: Text('Info'),
                              ),
                            ],
                            onChanged: (value) {
                              // Handle dropdown selection
                            },
                          ),
                        ),
                      ),
                       GestureDetector(
                         onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Notificationpage()));
                            },
                         child: SvgPicture.asset(
                          'assets/icons/notify.svg',
                          width: 23,
                          height: 23,
                                               ),
                       ),
                      SizedBox(width: 15,)
                    ],
                  ),
      body:SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:20.0),
          child: Column(
              children:[   
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Userprofilepage()));
                            },
                            child: CircleAvatar(
                              backgroundImage:AssetImage('assets/nophoto.png'),
                              radius: 18,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text('Welcome user', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromRGBO(108, 0, 144, 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 15, color: Colors.white,),
                          SizedBox(width: 8,),
                          Text('Add money', style: TextStyle(fontSize: 12, color: Colors.white))
                        ],
                      ),
                    )
                  ],
                ),            
                SizedBox(height: 15),
                Overview(),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ActiveUsersPage()));
                        },
                        child: Icontabs(icon: 'assets/icons/activeusers.svg', label: 'Active users',)),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> UserReviewPage()))
                        },
                        child: Icontabs(icon: 'assets/icons/reviews.svg', label: 'Reviews',)),
                      GestureDetector(
                        onTap: ()=>{
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> NewUsersPage()))
                        },
                        child: Icontabs(icon: 'assets/icons/newuser.svg', label: 'New users',)),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdatesPage()))
                        },
                        child: Icontabs(icon: 'assets/icons/update.svg', label: 'Update',)),
                    ],),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(31, 31, 31, 1)),),
                      Text('See all', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 14, fontWeight: FontWeight.bold,))
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(children: [
                        Recenttransactions(imageplaceholder: 'AJ', placeholdercolor: Color.fromRGBO(29, 58, 112, 0.1), placeholdertextcolor: Color.fromRGBO(1, 41, 241, 1), username: 'Akano James', usernameactivity: 'NECO Token Purchase', date: '20/4/25'),
                        SizedBox(height:20),
                        Recenttransactions(imageplaceholder: 'JO', placeholdercolor: Color.fromRGBO(29, 58, 112, 0.1), placeholdertextcolor: Color.fromRGBO(1, 41, 241, 1), username: 'Jessica Okie', usernameactivity: 'Airtime Subscription', date: '20/4/25'),
                        SizedBox(height:20),
                        Recenttransactions(imageplaceholder: 'A', placeholdercolor: Color.fromRGBO(241, 90, 1, 0.5), placeholdertextcolor: Color.fromRGBO(241, 90, 1, 1), username: 'Jessica Okie', usernameactivity: 'Cable TV Subscription', date: '20/4/25'),
                        SizedBox(height:20),
                        Recenttransactions(imageplaceholder: 'SJ', placeholdercolor: Color.fromRGBO(241, 90, 1, 0.5), placeholdertextcolor: Color.fromRGBO(241, 90, 1, 1), username: 'Sunday John', usernameactivity: 'NECO Token Purchase', date: '20/4/25'),
                        SizedBox(height:20),
                        Recenttransactions(imageplaceholder: 'IO', placeholdercolor: Color.fromRGBO(1, 241, 17, 0.5), placeholdertextcolor: Color.fromRGBO(1, 241, 17, 1), username: 'Ifeanyi Opara', usernameactivity: 'NECO Token Purchase', date: '20/4/25'),
                      ],),
                    ),
                  ),
                )
              ]
          ),
        ),),
    );
  }
}


class Icontabs extends StatelessWidget {
  const Icontabs({super.key, required this.icon, required this.label});
  final String icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Container(
            width: 63,
            height: 61,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 4), // changes position of shadow
                  ),
                ]
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          SizedBox(height: 6,),
          Text(label, style: TextStyle(color: Color.fromRGBO(62, 62, 62, 1), fontSize: 12, fontWeight: FontWeight.bold))
        ]
    );
  }
}


class Overview extends StatefulWidget {
  const Overview({super.key,});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  String hiddenamount = 'N 2,500,000';
  void _showamount(){
    if(hiddenamount == 'N 2,500,000'){
      setState(() {
        hiddenamount = 'N *****';
      });
    }else{
      setState(() {
        hiddenamount = 'N 2,500,000';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(18),
        width:double.infinity,
        height: 141,
        decoration:BoxDecoration(
            color: Color.fromRGBO(108, 0, 144, 1),
            borderRadius: BorderRadius.circular(12)
        ),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Text('Available Balance', style: TextStyle(color: Color.fromRGBO(215, 215, 215, 1), fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(hiddenamount, style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showamount,
                    child: SvgPicture.asset(
                      'assets/icons/view.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Money Point', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 16, fontWeight: FontWeight.normal)),
                  SizedBox(width: 8),
                  GestureDetector(
                     onTap: () {
                            Clipboard.setData(ClipboardData(text: "1100336447"));
                          },
                    child: SvgPicture.asset(
                      'assets/icons/copy.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('1100326447', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 16, fontWeight: FontWeight.normal)),
                ],
              ),
            ]
        )
    );
  }
}


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