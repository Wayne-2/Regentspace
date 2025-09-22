import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newregentspace/core/demo_pages/attachments/addmoney.dart';
import 'package:newregentspace/core/demo_pages/attachments/buypageshortcut.dart';
import 'package:newregentspace/core/demo_pages/attachments/electricityandcablebills.dart';
import 'package:newregentspace/core/demo_pages/attachments/notificationpage.dart';
import 'package:newregentspace/core/src/canva/widgets/icontabs.dart';

class HomepageDemo extends StatelessWidget {
  const HomepageDemo({
    super.key,
    required this.primaryapptheme,
    required this.iconthemeColor,
    required String? selectedBgImagePath,
  }) : _selectedBgImagePath = selectedBgImagePath;

  final Color primaryapptheme;
  final Color iconthemeColor;
  final String? _selectedBgImagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromRGBO(
                          168,
                          168,
                          168,
                          1,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'hello User',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                         onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddMoneyPage()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                            color: primaryapptheme,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, size: 14,color: iconthemeColor),
                              SizedBox(width: 10),
                              Text(
                                "Add Money",
                                style: TextStyle(fontSize: 14, color: iconthemeColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Notificationpage()),
                          );
                        },
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Stack(
                clipBehavior: Clip.hardEdge,
        
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _selectedBgImagePath == null
                        ? Image.asset(
                            'assets/newbg.png',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_selectedBgImagePath),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 150,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Balance",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "₦ 2,554,706",
                          style: GoogleFonts.lato(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryapptheme,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start,
                          children: [
                            Text(
                              "Moniepoint",
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 16
                              ),
                            ),
                            SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: "1100336447",
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "1100336447",
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Top-up Services",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 180, // instead of 200
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyPage(
                              pageTitle: 'Buy Airtime',
                              planLabel: 'Amount',
                              planHint: 'Enter amount',
                              mobileLabel: 'Phone Number',
                              mobileHint: 'Enter phone number',
                              plans: ['₦ 500',
                                '₦ 1000',
                                '₦ 2000',
                                '₦ 5000',
                              ],
                              purchaseType: 'Airtime',
                            ),
                          ),
                        );
                      },
                      child: Icontabs(
                        icon: Icons.phone_android,
                        color: iconthemeColor,
                        label: 'Airtime',
                        themecolor: primaryapptheme, 
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyPage(
                              pageTitle: 'Buy Data',
                              planLabel: 'Select Plan',
                              planHint: 'Choose data plan',
                              mobileLabel: 'Phone Number',
                              mobileHint: 'Enter phone number',
                              plans: [
                                '₦ 500 1.5GB',
                                '₦ 1000 3GB',
                                '₦ 1500 5GB',
                                '₦ 2000 10GB',
                              ],
                              purchaseType: 'Data',
                            ),
                          ),
                        );
                      },
                      child: Icontabs(
                        icon: Icons.wifi,
                        color: iconthemeColor,
                        label: 'data',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap:(){
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuyUtilityPage(
                              title: "Buy Electricity",
                              transactionType: "Electricity Purchase",
                            ),
                          ),
                        );                    
                      },
                      child: Icontabs(
                        icon: Icons.bolt,
                        color: iconthemeColor,
                        label: 'electric',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuyUtilityPage(
                              title: "Buy Cable TV",
                              transactionType: "Cable TV Purchase",
                            ),
                          ),
                        );
                      },
                      child: Icontabs(
                        icon: Icons.tv,
                        color: iconthemeColor,
                        label: 'Cable',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap:(){},
                      child: Icontabs(
                        icon: Icons.sports_soccer,
                        color: iconthemeColor,
                        label: 'Betting',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap:(){},
                      child: Icontabs(
                        icon: Icons.flight,
                        color: iconthemeColor,
                        label: 'Flight',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap:(){},
                      child: Icontabs(
                        icon: Icons.shopping_cart,
                        color: iconthemeColor,
                        label: 'Shop',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap:(){},
                      child: Icontabs(
                        icon: Icons.generating_tokens,
                        color: iconthemeColor,
                        label: 'Results',
                        themecolor: primaryapptheme,
                        height: 60, 
                        width: 60, 
                        iconsize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Advertisements",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: 250,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage('assets/ads1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 250,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage('assets/ads2.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
                top: 30,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
      ],
    );
  }
}
