import 'package:newregentspace/core/src/canva/canva.dart';

// import 'regentcanvapage.dart';
import '../src/dashboard/dashboard.dart';
import '../src/finances/finance.dart';
import '../src/settings/setting.dart';
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
  late final RegentFinancePage finance;
  late final RegentSettings settings;

  @override
  void initState() {
    super.initState();
    dashboard = Dashboard();
    canva = Regentcanva();
    finance = RegentFinancePage();
    settings = RegentSettings();
    pages = [dashboard, canva, finance, settings];
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
            icon: Icon(Icons.dashboard_customize_rounded),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/billsicon.png")),
            icon: Icon(Icons.add_box_outlined),
            label: 'Canvas',
          ),
          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/moreicon.png")),
            icon: Icon(Icons.wallet_outlined),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            //icon: ImageIcon(AssetImage("images/settingsicon.png")),
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}