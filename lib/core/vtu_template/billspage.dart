import 'package:flutter/material.dart';

final Color darkBlue = Color(0xFF0B3C6F);
final Color balanceCardColor = Color(0xFF7063E4);


class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bill Payment',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Refer and Earn Banner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6945D1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Text(
                            'Refer and Earn',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Refer a friend and win ₦500',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            onPressed: null,
                            child: Text(
                              'Refer Now',
                              style: TextStyle(
                                  color: Color(0xFF6945D1),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'images/thumbsup.png',
                      height: 101.46,
                      width: 103.11,
                    ),
                  ],
                ),
              ),
            ),

            // Recent List (right screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recents",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildRecentItem("images/airtel.png", "0909412201"),
                        _buildRecentItem("images/William.png", "Loui William"),
                        _buildRecentItem("images/mtn.png", "0909461201"),
                        _buildRecentItem("images/glo.png", "0908432201"),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Biller Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Biller List",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.8,
                children: [
                  _buildBillerItem("images/Airtime.png", "Airtime"),
                  _buildBillerItem("images/Electricbill.png", "Electric bill"),
                  _buildBillerItem("images/Television.png", "Television"),
                  _buildBillerItem("images/Internet.png", "Internet"),
                  _buildBillerItem("images/Market.png", "Market"),
                  _buildBillerItem("images/Medical.png", "Medical"),
                  _buildBillerItem("images/Television.png", "Television"),
                  _buildBillerItem("images/Waterbill.png", "Waterbill"),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String imagePath, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  static Widget _buildBillerItem(String imagePath, String label) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset(imagePath, width: 28, height: 28),
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
}

