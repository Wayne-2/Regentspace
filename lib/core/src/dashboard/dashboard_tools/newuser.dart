import 'package:flutter/material.dart';

class NewUsersPage extends StatelessWidget {
  NewUsersPage({super.key});
  final List<Map<String, String>> users = [
    {"name": "Akano James", "image": "assets/images/pic1.png"},
    {"name": "Uchechi Uzor", "image": "assets/images/pic2.png"},
    {"name": "Mrs Ifebo", "image": "assets/images/pic3.png"},
    {"name": "Catherine", "image": "assets/images/pic4.png"},
    {"name": "Matthew Peter", "image": "assets/images/pic5.png"},
    {"name": "Isa Musa", "image": "assets/images/pic6.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor:  Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "New Users",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: users.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 154 / 177, // Ensures box size
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return userCard(
                      name: user["name"]!,
                      imagePath: user["image"]!,
                    );
                  },
                ),
              ),
            ),

            // View Others
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: 151,
                decoration: BoxDecoration(
                  color: Colors.grey[100], // background color
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(57, 158, 158, 158),
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "View Older",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget userCard({required String name, required String imagePath}) {
    return Container(
      width: 154,
      height: 177,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(64, 158, 158, 158),
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 41, // 82 diameter
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            "recently joined",
            style: TextStyle(fontSize: 12, color: Colors.green[700]),
          ),
        ],
      ),
    );
  }
}