import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Finances extends StatelessWidget {
  const Finances({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 230, 255, 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello Again",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color.fromRGBO(140, 140, 140, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Odeh Solomon",
                        style: GoogleFonts.urbanist(
                          fontSize: 20,
                          color: const Color.fromRGBO(64, 62, 62, 1),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Tier 1 Retailer",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          image: const DecorationImage(
                            image: AssetImage("assets/nophoto.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==== BALANCE SECTION ====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Left: Total Balance ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Balance",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color.fromRGBO(112, 112, 112, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "N24,500.00",
                        style: GoogleFonts.urbanist(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_drop_down,
                              size: 18, color: Color.fromRGBO(153, 0, 100, 1)),
                          Text(
                            "4000 (25% interest)",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color.fromRGBO(153, 0, 100, 1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 155,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      color: const Color.fromRGBO(234, 197, 247, 1),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.15),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Withdrawal Wallet",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color.fromRGBO(76, 76, 76, 1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Opay acc LTD",
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: const Color.fromRGBO(151, 151, 151, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const VerticalDivider(
                            color: Colors.black26,
                            thickness: 0.8,
                          ),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: Color.fromRGBO(16, 16, 16, 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    "Manage Account",
                    filled: true,
                  ),
                  _buildActionButton(
                    "Monitor Interest",
                    outlined: true,
                  ),
                  _buildActionButton(
                    "Upgrade Tier",
                    light: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color.fromRGBO(234, 197, 247, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Header ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Finance summary",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(74, 0, 99, 1),
                          ),
                        ),
                        Row(
                          children: [
                            _buildSummaryStat(
                                "Today's Earnings", "N2000.00"),
                            const SizedBox(width: 10),
                            Container(width: 1, height: 24, color: Colors.black26),
                            const SizedBox(width: 10),
                            _buildSummaryStat(
                                "Week's Earnings", "N5300.00"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryDetail(
                            "Percentage Interest", "25% per Earnings"),
                        _buildSummaryDetail(
                            "Withdrawal Balance", "N22,550.00", alignRight: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(31, 31, 31, 1)),
                  ),
                  Text(
                    'See all',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: const [
                    SizedBox(height: 8),
                    Recenttransactions(
                        imageplaceholder: 'AJ',
                        placeholdercolor: Color.fromRGBO(29, 58, 112, 0.1),
                        placeholdertextcolor: Color.fromRGBO(1, 41, 241, 1),
                        username: 'Akano James',
                        usernameactivity: 'NECO Token Purchase',
                        date: '20/4/25'),
                    SizedBox(height: 18),
                    Recenttransactions(
                        imageplaceholder: 'JO',
                        placeholdercolor: Color.fromRGBO(29, 58, 112, 0.1),
                        placeholdertextcolor: Color.fromRGBO(1, 41, 241, 1),
                        username: 'Jessica Okie',
                        usernameactivity: 'Airtime Subscription',
                        date: '20/4/25'),
                    SizedBox(height: 18),
                    Recenttransactions(
                        imageplaceholder: 'A',
                        placeholdercolor: Color.fromRGBO(241, 90, 1, 0.5),
                        placeholdertextcolor: Color.fromRGBO(241, 90, 1, 1),
                        username: 'Jessica Okie',
                        usernameactivity: 'Cable TV Subscription',
                        date: '20/4/25'),
                    SizedBox(height: 18),
                    Recenttransactions(
                        imageplaceholder: 'SJ',
                        placeholdercolor: Color.fromRGBO(241, 90, 1, 0.5),
                        placeholdertextcolor: Color.fromRGBO(241, 90, 1, 1),
                        username: 'Sunday John',
                        usernameactivity: 'NECO Token Purchase',
                        date: '20/4/25'),
                    SizedBox(height: 18),
                    Recenttransactions(
                        imageplaceholder: 'IO',
                        placeholdercolor: Color.fromRGBO(1, 241, 17, 0.5),
                        placeholdertextcolor: Color.fromRGBO(1, 241, 17, 1),
                        username: 'Ifeanyi Opara',
                        usernameactivity: 'NECO Token Purchase',
                        date: '20/4/25'),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text,
      {bool filled = false, bool outlined = false, bool light = false}) {
    return Container(
      width: 120,
      height: 43,
      decoration: BoxDecoration(
        color: filled
            ? const Color.fromRGBO(153, 0, 204, 1)
            : light
                ? const Color.fromRGBO(234, 197, 247, 1)
                : Colors.white,
        border: outlined
            ? Border.all(
                color: const Color.fromRGBO(153, 0, 204, 1),
                width: 1.0,
              )
            : null,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: filled
                ? Colors.white
                : const Color.fromRGBO(153, 0, 204, 1),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 9,
                color: const Color.fromRGBO(191, 0, 255, 1),
                fontWeight: FontWeight.w500)),
        Text(value,
            style: GoogleFonts.urbanist(
                fontSize: 11,
                color: const Color.fromRGBO(10, 0, 13, 1),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummaryDetail(String label, String value,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color.fromRGBO(38, 38, 38, 1),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: const Color.fromRGBO(15, 15, 15, 1),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class Recenttransactions extends StatelessWidget {
  const Recenttransactions({
    super.key,
    required this.imageplaceholder,
    required this.placeholdercolor,
    required this.placeholdertextcolor,
    required this.username,
    required this.usernameactivity,
    required this.date,
  });

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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: placeholdercolor,
          ),
          child: Center(
            child: Text(
              imageplaceholder,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: placeholdertextcolor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black),
                  ),
                  Text(
                    usernameactivity,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6)),
                  ),
                ],
              ),
              // Right side
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "N3000.00",
                    style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
