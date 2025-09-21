import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newregentspace/core/src/canva/widgets/icontabs.dart';

class FullHomepageDisplay extends StatelessWidget {
  const FullHomepageDisplay({
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
    return Padding(
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
                  Container(
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
                  SizedBox(width: 10),
                  Icon(
                    Icons.notifications_outlined,
                    size: 20,
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
                Icontabs(
                  icon: Icons.phone_android,
                  color: iconthemeColor,
                  label: 'Airtime',
                  themecolor: primaryapptheme, 
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.wifi,
                  color: iconthemeColor,
                  label: 'data',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.bolt,
                  color: iconthemeColor,
                  label: 'electric',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.tv,
                  color: iconthemeColor,
                  label: 'Cable',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.sports_soccer,
                  color: iconthemeColor,
                  label: 'Betting',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.flight,
                  color: iconthemeColor,
                  label: 'Flight',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.shopping_cart,
                  color: iconthemeColor,
                  label: 'Shop',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
                ),
                Icontabs(
                  icon: Icons.generating_tokens,
                  color: iconthemeColor,
                  label: 'Results',
                  themecolor: primaryapptheme,
                  height: 60, 
                  width: 60, 
                  iconsize: 20,
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
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            height: 50,
            color: primaryapptheme,
          ),
        ],
      ),
    );
  }
}
