import 'package:newregentspace/constructs/disputedetails.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(home: FeedbackPage()));
}

class FeedbackItemData {
  final String name;
  final String dateTime;
  final String amount;
  final String status;
  final String? descriptionOverride;

  FeedbackItemData({
    required this.name,
    required this.dateTime,
    required this.amount,
    required this.status,
    this.descriptionOverride,
  });
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String selectedTab = "All";




  //Solomon note that I'm testing the class that handles the feedback cards with this dummy data
  final List<FeedbackItemData> allFeedbacks = [
    // Test feedback cards
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'May 24th, 2025 08:35:58',
      amount: '₦10000.00',
      status: 'Completed',
      descriptionOverride: 'Successful but not credited',
    ),
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'May 20th, 2025 16:37:24',
      amount: '₦10100.00',
      status: 'Processing',
      descriptionOverride: 'Successful but not credited',
    ),

    // Real transaction-style cards
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'July 30th, 2025 10:15:42',
      amount: '₦8500.00',
      status: 'Completed',
    ),
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'July 25th, 2025 17:22:11',
      amount: '₦4300.00',
      status: 'Processing',
    ),
  ];





  List<FeedbackItemData> get filteredFeedbacks {
    if (selectedTab == "All") return allFeedbacks;
    return allFeedbacks.where((item) => item.status == selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Feedback",
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _tabItem("All"),
                _tabItem("Processing"),
                _tabItem("Completed"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFeedbacks.length,
              itemBuilder: (context, index) {
                final feedback = filteredFeedbacks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,


                      MaterialPageRoute(
                        builder: (_) => DisputeDetailsPage(
                          ticketId: 'DUMMY-${index + 1}',

                          //Im using two conditions for question type because, since you havent done backend
                          //Cards can't tell if the transaction is completed or still processing
                          questionType: feedback.descriptionOverride ?? feedback.status,
                          //I'll use name cuz theres no phone number yet
                          recipientMobile: feedback.name,
                          amount: feedback.amount,
                          date: feedback.dateTime,
                          status: feedback.status,
                        ),
                      ),


                    );
                  },
                  child: FeedbackItem(feedback: feedback),
                );
              },

            ),
          ),

          SizedBox(height: 50)
        ],
      ),
    );
  }



  //For the All, Processing and Completed overhead Tabs

  Widget _tabItem(String title) {
    final bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDFF6DD) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




class FeedbackItem extends StatelessWidget {
  final FeedbackItemData feedback;

  const FeedbackItem({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final String headerText = feedback.descriptionOverride ?? feedback.status;
    final String recipientText = "By ${feedback.name}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status", style: TextStyle(color: Colors.grey)),
              Chip(
                label: Text(
                  feedback.status,
                  style: const TextStyle(color: Colors.grey),
                ),
                backgroundColor: const Color(0xFFEDEDED),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipientText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transaction Date",
                  style: TextStyle(color: Colors.black87)),
              Text(feedback.dateTime,
                  style: const TextStyle(color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transaction Amount",
                  style: TextStyle(color: Colors.black87)),
              Text(feedback.amount,
                  style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}








/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(home: FeedbackPage()));
}

class FeedbackItemData {
  final String name;
  final String dateTime;
  final String amount;
  final String status;
  final String? descriptionOverride;

  FeedbackItemData({
    required this.name,
    required this.dateTime,
    required this.amount,
    required this.status,
    this.descriptionOverride,
  });
}

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String selectedTab = "All";




  //Solomon note that I'm testing the class that handles the feedback cards with this dummy data
  final List<FeedbackItemData> allFeedbacks = [
    // Test feedback cards
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'May 24th, 2025 08:35:58',
      amount: '₦10000.00',
      status: 'Completed',
      descriptionOverride: 'Successful but not credited',
    ),
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'May 20th, 2025 16:37:24',
      amount: '₦10100.00',
      status: 'Processing',
      descriptionOverride: 'Successful but not credited',
    ),

    // Real transaction-style cards
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'July 30th, 2025 10:15:42',
      amount: '₦8500.00',
      status: 'Completed',
    ),
    FeedbackItemData(
      name: 'CHIEF SOLOMON',
      dateTime: 'July 25th, 2025 17:22:11',
      amount: '₦4300.00',
      status: 'Processing',
    ),
  ];





  List<FeedbackItemData> get filteredFeedbacks {
    if (selectedTab == "All") return allFeedbacks;
    return allFeedbacks.where((item) => item.status == selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Feedback",
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _tabItem("All"),
                _tabItem("Processing"),
                _tabItem("Completed"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFeedbacks.length,
              itemBuilder: (context, index) {
                return FeedbackItem(feedback: filteredFeedbacks[index]);
              },
            ),
          ),

          SizedBox(height: 50)
        ],
      ),
    );
  }



  //For the All, Processing and Completed overhead Tabs

  Widget _tabItem(String title) {
    final bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDFF6DD) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




class FeedbackItem extends StatelessWidget {
  final FeedbackItemData feedback;

  const FeedbackItem({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final String headerText = feedback.descriptionOverride ?? feedback.status;
    final String recipientText = "By ${feedback.name}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status", style: TextStyle(color: Colors.grey)),
              Chip(
                label: Text(
                  feedback.status,
                  style: const TextStyle(color: Colors.grey),
                ),
                backgroundColor: const Color(0xFFEDEDED),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipientText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transaction Date",
                  style: TextStyle(color: Colors.black87)),
              Text(feedback.dateTime,
                  style: const TextStyle(color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transaction Amount",
                  style: TextStyle(color: Colors.black87)),
              Text(feedback.amount,
                  style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}


*/
















