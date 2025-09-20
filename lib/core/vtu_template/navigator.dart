import 'billspage.dart';
import 'home.dart';
import 'settingspage.dart';
import 'morepage.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late final List<Widget> pages;
  late final WalletHomePage walletHomePage;
  late final SettingsPage settingsPage;
  late final BillsPage billsPage;
  late final MorePage morePage;

  @override
  void initState() {
    super.initState();
    walletHomePage = WalletHomePage();
    billsPage = BillsPage();
    morePage = MorePage();
    settingsPage = SettingsPage();
    pages = [walletHomePage, billsPage, morePage, settingsPage];
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
            icon: ImageIcon(AssetImage("images/homeicon.png")),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("images/billsicon.png")),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("images/moreicon.png")),
            label: 'More',
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





/*
import 'package:chiefsolomonfirstwork/billspage.dart';
import 'package:chiefsolomonfirstwork/home.dart';
import 'package:chiefsolomonfirstwork/settingspage.dart';
import 'package:chiefsolomonfirstwork/morepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


class BottomNav extends StatefulWidget{
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>{
  int currentTabIndex=0;

  late List<Widget> pages;
  late Widget currentPage;
  late WalletHomePage walletHomePage;
  late LoanPage loanPage;
  late BillsPage billsPage;
  late MorePage morePage;

  @override
  void initState() {
    walletHomePage=WalletHomePage();
    loanPage=LoanPage();
    billsPage=BillsPage();
    morePage=MorePage();
    pages = [walletHomePage, loanPage, billsPage, morePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Color(0xFF1F1F1F),
        color: Colors.white,
        animationDuration: Duration(milliseconds: 250),
        onTap: (int index){
          setState(() {
            currentTabIndex=index;
          });
        },
        items: [
          Image(image: AssetImage("images/homeicon.png"), color: Colors.black),
          Image(image: AssetImage("images/loanicon.png"), color: Colors.black),
          Image(image: AssetImage("images/billsicon.png"), color: Colors.black),
          Image(image: AssetImage("images/moreicon.png"), color: Colors.black),

        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}

 */