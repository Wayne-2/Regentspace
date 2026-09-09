import 'package:flutter/material.dart';
import 'pages/canva/canva.dart';
import 'pages/dashboard/dashboard.dart';
import 'pages/finances/finance.dart';
import 'pages/profile/profile.dart';
import 'service/build_tracker.dart';

/// Global tab controller — canva switches to dashboard after build submit.
final ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);

class RegentBottomNav extends StatefulWidget {
  const RegentBottomNav({super.key});

  @override
  State<RegentBottomNav> createState() => _RegentBottomNavState();
}

class _RegentBottomNavState extends State<RegentBottomNav> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentTabNotifier.addListener(_onTabChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    currentTabNotifier.removeListener(_onTabChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BuildTracker.instance.refreshActiveBuilds();
    }
  }

  void _onTabChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentTabNotifier.value,
        children: const [
          Dashboard(),
          Regentcanva(),
          Finances(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabNotifier.value,
        onTap: (int index) {
          currentTabNotifier.value = index;
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
