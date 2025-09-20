
import 'addmoney.dart';
import 'buypageshortcut.dart';
import 'electricityandcablebills.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CashlessOweHomePage extends StatelessWidget {
  CashlessOweHomePage({super.key});
  final Color darkBlue = Color(0xFF0B3C6F);
  final Color balanceCardColor = Color(0xFF7063E4);

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
                    "Hi, User 👋🏿",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddMoneyPage()),
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

                ],
              ),

              SizedBox(height: 16),

              // Balance Card
              Container(
                width: double.infinity,
                height: 141,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: balanceCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "You Owe",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            "₦ 0.00",
                            style: GoogleFonts.lato(
                              fontSize: 27,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Image(image: AssetImage("images/view 3.png")),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Repayment Date: ",
                          style: GoogleFonts.lato(
                            fontSize: 16.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "N/A",
                          style: GoogleFonts.lato(
                            fontSize: 16.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Services
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  serviceButton("images/phone.png", "Airtime", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BuyPage(
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
                              // You can keep this empty as well and there will be no dropdown
                              purchaseType: 'Airtime',
                            ),
                      ),
                    );
                  }),
                  serviceButton("images/wifi.png", "Data", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BuyPage(
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
                  }),
                  serviceButton("images/tv.png", "Cable TV", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const BuyUtilityPage(
                          title: "Buy Cable TV",
                          transactionType: "Cable TV Purchase",
                        ),
                      ),
                    );
                  }),

                  serviceButton("images/bulb.png", "Electricity", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const BuyUtilityPage(
                          title: "Buy Electricity",
                          transactionType: "Electricity Purchase",
                        ),
                      ),
                    );
                  }),
                ],
              ),


              SizedBox(height: 24),


              Center(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(68, 0, 0, 0), // Shadow color
                          spreadRadius: 2, // How wide the shadow spreads
                          blurRadius: 10, // Softness of the shadow
                          offset: Offset(0, 4), // Horizontal and vertical offset
                        ),
                      ],
                    color: Color(0xFFE8F0FF)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 24,
                          width: 24,
                          child: Icon(Icons.info, color: Color(0xFF1D3A70,),)),
                      SizedBox(width: 10),
                      Text('Complete Setting Up Your FinPadi Account', style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),)
                    ],
                  ),
                ),

                //child: Image(image: AssetImage('images/setup.png')),
              ),


              SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),

              SizedBox(height: 70),


              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text(
                    'Once Your Account Is Credited And You Start Making Transactions You’ll see them here',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w400, fontSize: 16, color: Color(0xFF8C8C8C)
                    ),
                    textAlign: TextAlign.center,
                  )
                  ),
                ],
              )
              /*
              Row(
                children: [
                  Icon(Icons.access_time_filled,
                      size: 16, color: Colors.grey[600]),
                  SizedBox(width: 6),
                  Text(
                    "Today",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
               */


              /*
              SizedBox(height: 8),

              // Transactions List (scrollable only for this section)
              Flexible(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    transactionTile(
                      title: "Loan Repayment",
                      time: "10:30pm",
                      amount: "-₦ 1,800,400",
                      isDebit: true,
                      imagePath: "images/loan.png",
                    ),
                    transactionTile(
                      title: "Wallet Top Up",
                      time: "5:45pm",
                      amount: "+₦ 2,500",
                      isDebit: false,
                      imagePath: "images/topup.png",
                    ),
                    transactionTile(
                      title: "Victor Isaac",
                      time: "10:45pm",
                      amount: "+₦ 800,000",
                      isDebit: false,
                      imagePath: "images/vi.png",
                    ),
                  ],
                ),
              ),

               */

            ],
          ),
        ),
      ),
    );
  }
}


Widget serviceButton(String imagePath, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 57.82,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.black87)),
      ],
    ),
  );
}

/*
  Widget transactionTile({
    required String title,
    required String time,
    required String amount,
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
            color: Colors.grey.withOpacity(0.15),
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
              child: Image.asset(
                imagePath,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: isDebit ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

 */
