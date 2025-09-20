import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newregentspace/core/src/canva/canva_tools/icontabs.dart';

class HomePageTemplate extends StatelessWidget {
  const HomePageTemplate({
    super.key,
    required this.primaryapptheme,
    required String? selectedBgImagePath,
  }) : _selectedBgImagePath = selectedBgImagePath;

  final Color primaryapptheme;
  final String? _selectedBgImagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Color.fromRGBO(
                      168,
                      168,
                      168,
                      1,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'hello User',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
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
                        Icon(Icons.add_circle, size: 8),
                        SizedBox(width: 4),
                        Text(
                          "Add Money",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.notifications_outlined,
                    size: 10,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6),
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
                        width: 175,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_selectedBgImagePath),
                        width: 175,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
              ),
              Container(
                width: 175,
                height: 70,
                padding: EdgeInsets.all(6),
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
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "₦ 2,554,706",
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Color.fromARGB(
                          225,
                          253,
                          83,
                          0,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Text(
                          "Moniepoint",
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 10.5,
                          ),
                        ),
                        SizedBox(width: 3),
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
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "1100336447",
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 10.5,
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
          SizedBox(height: 6),
          Text(
            "Top-up Services",
            style: TextStyle(fontSize: 10),
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 175,
            height: 120, // instead of 200
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.7,
              children: [
                Icontabs(
                  icon: Icons.phone_android,
                  label: 'Airtime',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.wifi,
                  label: 'data',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.bolt,
                  label: 'electric',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.tv,
                  label: 'Cable',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.sports_soccer,
                  label: 'Betting',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.flight,
                  label: 'Flight',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.shopping_cart,
                  label: 'Shop',
                  themecolor: primaryapptheme,
                ),
                Icontabs(
                  icon: Icons.generating_tokens,
                  label: 'Results',
                  themecolor: primaryapptheme,
                ),
              ],
            ),
          ),
          SizedBox(height: 3),
          Text(
            "Advertisements",
            style: TextStyle(fontSize: 10),
          ),
          SizedBox(height: 5),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 175,
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
                  width: 175,
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
            height: 20,
            color: primaryapptheme,
          ),
        ],
      ),
    );
  }
}
