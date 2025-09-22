import 'package:flutter/material.dart';
import 'package:newregentspace/core/demo_pages/pages/finances.dart';
import 'package:newregentspace/core/demo_pages/pages/homepage.dart';
import 'package:newregentspace/core/demo_pages/pages/settings.dart';

class BottomNav extends StatefulWidget {
  final Color appNameColor;
  final Color myColor;
  final Color primaryapptheme;
  final Color homePagebgColor;
  final Color iconthemeColor;
  final String? selectedBgImagePath;

  const BottomNav({
    super.key,
    required this.appNameColor,
    required this.myColor,
    required this.primaryapptheme,
    required this.homePagebgColor,
    required this.iconthemeColor,
    required this.selectedBgImagePath,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late final List<Widget> pages;
  late final HomepageDemo homePage;
  late final SettingsDemo settingsPage;
  late final FinancesDemo financesPage;

  @override
  void initState() {
    super.initState();
    homePage = HomepageDemo(
      primaryapptheme: widget.primaryapptheme,
      iconthemeColor: widget.iconthemeColor,
      selectedBgImagePath: widget.selectedBgImagePath,
    );
    financesPage = FinancesDemo(
      primaryapptheme: widget.primaryapptheme,
    );
    settingsPage = SettingsDemo();

    pages = [
      homePage,
      financesPage,
      settingsPage,
    ];
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Finances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
