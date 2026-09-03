import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NewUsersPage extends StatelessWidget {
  const NewUsersPage({super.key});

  static const mockUsers = [
    {'username': 'Akano James', 'email': 'akano@example.com', 'created_at': 'Apr 20, 2025 - 10:30 AM'},
    {'username': 'Jessica Okie', 'email': 'jessica@example.com', 'created_at': 'Apr 19, 2025 - 02:15 PM'},
    {'username': 'Sunday John', 'email': 'sunday@example.com', 'created_at': 'Apr 18, 2025 - 06:00 PM'},
    {'username': 'Ifeanyi Opara', 'email': 'ifeanyi@example.com', 'created_at': 'Apr 17, 2025 - 11:20 AM'},
    {'username': 'Ada Loveth', 'email': 'ada@example.com', 'created_at': 'Apr 16, 2025 - 09:00 AM'},
  ];

  String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 2).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('New Users', style: TextStyle(fontFamily: 'DMSans', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        actions: [IconButton(icon: const Icon(Icons.search_rounded, color: Colors.black54), onPressed: () {})],
      ),
      body: ListView.builder(
        itemCount: mockUsers.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          final user = mockUsers[index];
          final name = user['username']!;
          final email = user['email']!;
          final joined = user['created_at']!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      getInitials(name),
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(name, style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary.withValues(alpha: 0.85))),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 2),
                    Text('Joined $joined', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w400)),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
