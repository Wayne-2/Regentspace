import 'package:flutter/material.dart';

class UserReviewPage extends StatelessWidget {
  const UserReviewPage({super.key});
    @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(235, 240, 240, 240),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
          title: Text(
            "User Reviews",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                ReviewCard(
                    review: 'the app functionality is good but, i am having issues logining in, after every three trials',
                    onTap: () {},
                    leading: AssetImage("assets/images/pic2.png"),
                    username: 'Uchechi Uzor',
                    date: '11-05-01'
                ),
                SizedBox(height: 15),
                ReviewCard(
                    review: 'the app functionality is good but, i am having issues logining in, after every three trials',
                    onTap: () {},
                    leading:  AssetImage("assets/images/pic2.png"),
                    username: 'Uchechi Uzor',
                    date: '11-05-01'
                ),
                SizedBox(height: 15),
                ReviewCard(
                    review: 'the app functionality is good but, i am having issues logining in, after every three trials',
                    onTap: () {},
                    leading: AssetImage("assets/images/pic2.png"),
                    username: 'Uchechi Uzor',
                    date: '11-05-01'
                )
              ],
            ),
          ),
        )
    );
  }
}









class ReviewCard extends StatelessWidget {
  final String review;
  final VoidCallback onTap;
  final ImageProvider leading;
  final String username;
  final String date;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onTap,
    required this.leading,
    required this.username,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    review,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundImage: leading,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
