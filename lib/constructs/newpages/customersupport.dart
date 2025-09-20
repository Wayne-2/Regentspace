import 'package:newregentspace/constructs/newpages/feedbacklist.dart';
import 'package:newregentspace/constructs/newpages/officeaddress.dart';
import 'package:newregentspace/constructs/newpages/securitycenter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFD9E1FF),//Color(0xFFEBEBEB),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Customer Service",
            style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 12),
                      Image(image: AssetImage('assets/images/clientsupport.png') , height: 48, width: 48,),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          Text("Hello, Chief Solomon",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          Text("How can we help you?", style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),)
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                        child: GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.8,
                          children: [
                            //You can use images as well
                            //_SupportItem("Transfer Dispute", imagePath: "images/Airtime.png"),
                            _SupportItem("Transfer Dispute", icon: Icons.fact_check),
                            _SupportItem("Erroneous Transfer Recall", icon: Icons.no_transfer_outlined),
                            _SupportItem("Lift Restrictions", icon: Icons.lock_open_outlined),
                            _SupportItem("Apply card", icon: Icons.credit_card),
                            _SupportItem("Login and Repayment", icon: Icons.lock),
                            _SupportItem("Account Limits", icon: Icons.security_update_warning_outlined),
                            _SupportItem("Mobile Number Change", icon: Icons.phone_android),
                            _SupportItem("Report Scam", icon: Icons.report),

                          ],
                        ),
                      ),
                    ),
                  ),



                  SizedBox(height: 5),



                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Feedback", style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                  child: Row(
                                    children: const [
                                      Text("More", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.navigate_next_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white54
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Successful but not credited", style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),),
                                      Text("May 25th, 2025 14:02:20", style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),)
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Completed"),
                                    Icon(Icons.navigate_next_outlined)
                                  ],
                                ),
                              )],
                            ),

                          )


                          )
                        ],
                      ),

                    ),
                  ),




                  SizedBox(height: 5),



                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecurityCenterPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 81,
                        decoration: BoxDecoration(
                          color: Colors.white,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.shield, color: Color(0xFF7063E4),),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Text("Security Center", style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                    Text("Tap to report a scam or restrict your account", style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),)
                                  ],
                                ),
                              ),
                              Icon(Icons.navigate_next_outlined)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),





                  SizedBox(height: 5),



                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfficeAddressPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 81,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF7063E4)),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Office Address",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Customer Service Center Address",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Icon(Icons.navigate_next_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),


                  SizedBox(height: 50),


                ]
            )
        )
    );
  }
}



// ignore: non_constant_identifier_names
Widget _SupportItem(String label, {String? imagePath, IconData? icon}) {
  return Column(
    children: [
      Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          //borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: imagePath != null
              ? Image.asset(imagePath, width: 28, height: 28)
              : Icon(icon, size: 24, color: Color(0xFF7063E4)),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      )
    ],
  );
}

