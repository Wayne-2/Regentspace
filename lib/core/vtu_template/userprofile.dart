// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Userprofilepage extends StatefulWidget {
  const Userprofilepage({super.key});

  @override
  State<Userprofilepage> createState() => _UserprofilepageState();
}

class _UserprofilepageState extends State<Userprofilepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personal Details",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height:30),
              Stack(
                children: [
                   CircleAvatar(
                        backgroundImage:AssetImage('assets/nophoto.png'),
                        radius: 50,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(Icons.edit, color: Colors.black, size: 20,),)
                ],
              ),
              SizedBox(height: 20,),
              Infocontainer(label: 'Username', iconinfo: Icons.person, info: 'Chibuike Ikenga'),
              Infocontainer(label: 'Phone Number', iconinfo: Icons.phone, info:'08066265528'),
              Infocontainer(label: 'Email', iconinfo: Icons.email, info: "chykenga113@gmail.com"),
              Infocontainer(label: 'Date joined', iconinfo: Icons.calendar_view_day, info: '23rd march 2025')
            ]
          ),
        ),
      ),
    );
  }
}

class Infocontainer extends StatelessWidget {
  const Infocontainer({super.key, required this.label, required this.iconinfo, required this.info});
  final String label;
  final IconData iconinfo;
  final String info;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(iconinfo, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(info, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                 Icon(Icons.edit, color: Colors.grey, size: 14,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}