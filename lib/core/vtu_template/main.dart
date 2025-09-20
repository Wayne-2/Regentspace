// import 'activeusers.dart';
// import 'bankaccount.dart';
// import 'buyairtime.dart';
// import 'buydata.dart';
// import 'buypageshortcut.dart';
// import 'changepassword.dart';
// import 'electricityandcablebills.dart';
// import 'home.dart';
// import 'homeowetransactionless.dart';
// import 'homeowing.dart';
// import 'morepage.dart';
// import 'navigator.dart';
// import 'newuser.dart';
// import 'nextofkin.dart';
// import 'hometransactionless.dart';
// import 'profile.dart';
// import 'regentcanvapage.dart';
// import 'regentnavigator.dart';
// import 'regentspacedashboard.dart';
// import 'regentspacefinance.dart';
// import 'regentspacesetting.dart';
// import 'security.dart';
// import 'template.dart';
// import 'transactiondetails.dart';
// import 'transactionhistory.dart';
// import 'updates.dart';
// import 'userreview.dart';
// import 'verification.dart';
// import 'addmoney.dart';
// import 'package:flutter/material.dart';


// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       //home: const MyHomePage(title: 'Flutter Demo Home Page'),
//       //home: WalletHomePage(),
//       //home: TemplateGalleryPage(),
//       //home: NewUsersPage(),
//       //home: BuyAirtimePage(),
//       //home: BuyDataPage()
//       //home: BuyElectricityPage(),
//       //home: MorePage(),
//       //home: VerificationPage(),
//       //home: Nextofkin(),
//       //home: ProfilePage(),
//       //home: TransactionDetailsPage(transactionId: 'ni', date: 'aa', recipient: 's', type: 's', amount: '1', fee: 'q1', description: 'qi', total: '1'),
//       //home: Bankaccount(),
//       //home: AddMoneyPage(),
//       //home: SecurityPage(),
//       //home: Changepassword(),
//       home: BottomNav(),
//       //home: RegentFinancePage(),
//       //home: RegentSettings(),
//       //home: UserReviewPage(),
//       //home: UpdatesPage(),
//       //home: RegentCanvaPage(),
//       //home: Dashboard(),
//       //home: RegentBottomNav(),
//       //home: ActiveUsersPage(),
//       //home: CashlessWalletHomePage(),
//       //home: OwingHomePage(),
//       //home: CashlessOweHomePage(),


//       /*home: TransactionHistoryPage(
//         transactions: [
//           {
//             'title': 'Loan Repayment',
//             'time': '10:30pm',
//             'amount': '1,800.400',
//             'isCredit': false,
//             'icon': Image(image: AssetImage('images/loan.png'), height: 40, width: 40)//const Icon(Icons.account_balance_wallet),
//           },
//           {
//             'title': 'Wallet Top Up',
//             'time': '9:12am',
//             'amount': '2,500',
//             'isCredit': true,
//             'icon': Image(image: AssetImage('images/topup.png'), height: 40, width: 40)//const Icon(Icons.wallet),
//           },
//           {
//             'title': 'Victor Isaac',
//             'time': 'Yesterday',
//             'amount': '800.000',
//             'isCredit': true,
//             'icon': const Icon(Icons.person),
//           },
//           {
//             'title': 'DSTV Subscription',
//             'time': '2 days ago',
//             'amount': '4,500',
//             'isCredit': false,
//             'icon': Image(image: AssetImage('images/vi.png'), height: 40, width: 40)//const Icon(Icons.tv),
//           },
//           {
//             'title': 'Electricity',
//             'time': 'Last week',
//             'amount': '3,000',
//             'isCredit': false,
//             'icon': Image(image: AssetImage('images/dstv.png'), height: 40, width: 40)//const Icon(Icons.flash_on),
//           },
//           {
//             'title': 'Electricity',
//             'time': 'Last month',
//             'amount': '5,000',
//             'isCredit': false,
//             'icon': Image(image: AssetImage('images/electricity.png'), height: 40, width: 40)//const Icon(Icons.electric_bolt),
//           },
//         ],
//       ),

//        */




//       /*home: BuyPage(
//         pageTitle: 'Buy Airtime',
//         planLabel: 'Enter Amount',
//         planHint: '₦ 0.00',
//         mobileLabel: 'Enter Mobile Number',
//         mobileHint: '',
//         purchaseType: 'Airtime',
//         plans: [
//           '₦ 150',
//           '₦ 5000',
//           '₦ 500',
//           '₦ 900',
//         ],
//       ),

//        */





//      /* home: BuyPage(
//         pageTitle: 'Buy Data',
//         planLabel: 'Choose Data Plan',
//         planHint: '0.00 MB/GB',
//         mobileLabel: 'Enter Mobile Number',
//         mobileHint: '',
//         purchaseType: 'Data Bundle',
//         plans: [
//           '500 MB (30 days) @ ₦150',
//           '1 GB @ ₦200',
//           '2 GB @ ₦400',
//           '5 GB @ ₦900',
//         ],
//       ),

//       */


//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
