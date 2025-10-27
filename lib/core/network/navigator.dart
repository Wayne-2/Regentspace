import 'package:newregentspace/core/utils/pages/canva/canva.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/pages/dashboard/dashboard.dart';
import '../utils/pages/finances/finance.dart';
import '../utils/pages/profile/profile.dart';
import 'package:flutter/material.dart';

class RegentBottomNav extends StatefulWidget {
  const RegentBottomNav({super.key});

  @override
  State<RegentBottomNav> createState() => _RegentBottomNavState();
}

class _RegentBottomNavState extends State<RegentBottomNav> {
  int currentTabIndex = 0;

  late final List<Widget> pages;
  late final Dashboard dashboard;
  late final Regentcanva canva;
  late final Finances finance;
  late final ProfilePage profile;

  @override
  void initState() {
    super.initState();
    dashboard = Dashboard();
    canva = Regentcanva();
    finance = Finances();
    profile = ProfilePage();
    pages = [dashboard, canva, finance, profile];
  }

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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/homeicon.png")),
            icon: Icon(LucideIcons.layoutDashboard,),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/billsicon.png")),
            icon: Icon(LucideIcons.plusSquare,),
            label: 'Canvas',
          ),
          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/moreicon.png")),
            icon: Icon(LucideIcons.wallet),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/settingsicon.png")),
            icon: Icon(LucideIcons.userCircle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}