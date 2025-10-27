import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newregentspace/core/utils/pages/canva/widgets/icontabs.dart';

class HomePageTemplate extends StatelessWidget {
  const HomePageTemplate({
    super.key,
    required this.primaryapptheme,
    required this.iconthemeColor,
    required String? selectedBgImagePath,
  }) : _selectedBgImagePath = selectedBgImagePath;

  final Color primaryapptheme;
  final Color iconthemeColor;
  final String? _selectedBgImagePath;

  static const double _aspectRatio = 19.5 / 9; // iPhone 14 ratio

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 255, 232, 221),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Header Row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: Color.fromRGBO(168, 168, 168, 1),
                        ),
                        const SizedBox(width: 5),
                        const Text('hello User', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.black, width: 1),
                            color: primaryapptheme,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_circle,
                                  size: 8, color: iconthemeColor),
                              const SizedBox(width: 4),
                              Text(
                                "Add Money",
                                style: TextStyle(
                                    fontSize: 10, color: iconthemeColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.notifications_outlined, size: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                /// --- Account Card ---
                Stack(
            children: [
              Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: _selectedBgImagePath == null
                        ? const AssetImage('assets/newbg.png')
                        : FileImage(File(_selectedBgImagePath!))
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Balance",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₦ 2,554,706",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: primaryapptheme,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          "Moniepoint",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                const ClipboardData(text: "1100336447"));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account number copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.copy,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                "1100336447",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
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

                const SizedBox(height: 8),

                /// --- Services ---
                const Text("Top-up Services",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.8,
                  children: [
                    Icontabs(
                        icon: Icons.phone_android,
                        color: iconthemeColor,
                        label: 'Airtime',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.wifi,
                        color: iconthemeColor,
                        label: 'Data',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.bolt,
                        color: iconthemeColor,
                        label: 'Electric',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.tv,
                        color: iconthemeColor,
                        label: 'Cable',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.sports_soccer,
                        color: iconthemeColor,
                        label: 'Betting',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.flight,
                        color: iconthemeColor,
                        label: 'Flight',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.shopping_cart,
                        color: iconthemeColor,
                        label: 'Shop',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                    Icontabs(
                        icon: Icons.generating_tokens,
                        color: iconthemeColor,
                        label: 'Results',
                        themecolor: primaryapptheme,
                        height: 30,
                        width: 30,
                        iconsize: 12),
                  ],
                ),

                const SizedBox(height: 8),
                const Text("Advertisements",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),

                /// --- Ads Carousel ---
                SizedBox(
                  height: 70,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _adsCard('assets/ads1.png'),
                      const SizedBox(width: 10),
                      _adsCard('assets/ads2.png'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primaryapptheme,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _adsCard(String path) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image:
            DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
    );
  }
}
