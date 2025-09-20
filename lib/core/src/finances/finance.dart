import 'package:flutter_svg/svg.dart';

import '../../constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class RegentFinancePage extends StatelessWidget {
  RegentFinancePage({super.key});

  final Color darkBlue = Color(0xFF0B3C6F);
  final Color balanceCardColor = Color(0xFF7800A0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(23, 24, 23, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Finances",
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /*TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMoneyPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: Row(
                      children: const [
                        Text("Add Money"),
                        SizedBox(width: 6),
                        Icon(
                          Icons.add_circle,
                          color: Color.fromRGBO(29, 58, 112, 1),
                        ),
                      ],
                    ),
                  ),

                   */

                ],
              ),

              SizedBox(height: 16),

              // Balance Card
              Container(
                width: double.infinity,
                height: 189,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: balanceCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LIFETIME EARNING",
                      style: GoogleFonts.unbounded(
                  fontSize: 15,
                  color: Color(0xFFC955FF),
                  fontWeight: FontWeight.w600,
                ),

              ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "3000.00 NGN",
                          style: AppTextStyles.soraLarge
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  Text(
                    'Earnings',
                    style: GoogleFonts.unbounded(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFFC955FF),
                    ),
                  ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Today', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFFBCAFF), ), ),
                           Text(
                             '0.00 NGN',
                             style: GoogleFonts.unbounded(
                               fontWeight: FontWeight.w600,
                               fontSize: 14,
                               color: Color(0xFFFFFFFF),
                             ),
                           ),

                         ],

                       ),

                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('This week', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFFBCAFF)),),
                           Text(
                             '400.00 NGN',
                             style: GoogleFonts.unbounded(
                               fontWeight: FontWeight.w600,
                               fontSize: 14,
                               color: Color(0xFFFFFFFF),
                             ),
                           ),

                         ],
                         
                       )
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),


              // Recent Transactions
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Text(
                    "Transactions",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                 /* Text(
                    "See all",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  )

                  */
                ],
              ),


              SizedBox(height: 8),

              // Transactions List (scrollable only for this section)
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    transactionTile(
                      title: "Topups",
                      time: "Today 2:23pm",
                      amount: "+₦300",
                      isDebit: false,
                      imagePath: "assets/icons/upcash.svg",
                      deposit: "Deposit"
                    ),
                    transactionTile(
                      title: "Topups",
                      time: "Yesterday 1:12pm",
                      amount: "+₦500",
                      isDebit: false,
                      imagePath: "assets/icons/upcash.svg",
                        deposit: "Deposit"
                    ),
                    transactionTile(
                      title: "Topups",
                      time: "Last Week",
                      amount: "+₦150",
                      isDebit: false,
                      imagePath: "assets/icons/upcash.svg",
                        deposit: "Deposit"
                    ),
                    transactionTile(
                      title: "Topups",
                      time: "Last Week",
                      amount: "+₦150",
                      isDebit: false,
                      imagePath: "assets/icons/upcash.svg",
                        deposit: "Deposit"
                    ),
                    transactionTile(
                      title: "Topups",
                      time: "Last Week",
                      amount: "+₦150",
                      isDebit: false,
                      imagePath: "assets/icons/upcash.svg",
                        deposit: "Deposit"
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }




  Widget transactionTile({
    required String title,
    required String time,
    required String amount,
    required String deposit,
    required bool isDebit,
    required String imagePath,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(96, 158, 158, 158),
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SvgPicture.asset(
                imagePath,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(width: 12),

          // Title and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                deposit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
