import 'package:flutter/material.dart';

class Notificationpage extends StatelessWidget {
  const Notificationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Notificationcard(message: 'View monthly charts of new users, and active daily users', onTap: (){}, leading: AssetImage('assets/nophoto.png'), username: 'Regentspace', date: '10-november-2025'),
          Notificationcard(message: 'Funding of wallet was successful, tap to view info', onTap: (){}, leading: AssetImage('assets/nophoto.png'), username: 'Moniepoint', date: '10-november-2025'),
          Notificationcard(message: 'User review for the month of july is available', onTap: (){}, leading: AssetImage('assets/nophoto.png'), username: 'Regentspace', date: '10-july-2025'),
          Notificationcard(message: 'View monthly charts of new users, and active daily users', onTap: (){}, leading: AssetImage('assets/nophoto.png'), username: 'Regentspace', date: '10-november-2025')
        ],
      ),
    );
  }
}


class Notificationcard extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  final ImageProvider leading;
  final String username;
  final String date;

  const Notificationcard({
    super.key,
    required this.message,
    required this.onTap,
    required this.leading,
    required this.username,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        color: Colors.grey[100],
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
                      message,
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
      ),
    );
  }
}
