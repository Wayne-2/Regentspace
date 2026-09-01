import 'package:flutter/material.dart';
import 'pages/canva/canva.dart';
import 'pages/dashboard/dashboard.dart';
import 'pages/finances/finance.dart';
import 'pages/profile/profile.dart';

class RegentBottomNav extends StatefulWidget {
  const RegentBottomNav({super.key});

  @override
  State<RegentBottomNav> createState() => _RegentBottomNavState();
}

class _RegentBottomNavState extends State<RegentBottomNav> {
  int currentTabIndex = 0;

  final List<Widget> pages = const [
    Dashboard(),
    Regentcanva(),
    Finances(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF740690),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 6,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Canvas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
