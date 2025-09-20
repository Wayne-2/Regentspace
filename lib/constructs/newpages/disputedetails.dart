import 'package:newregentspace/constructs/newpages/livechat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisputeDetailsPage extends StatefulWidget {
  final String ticketId;
  final String questionType;
  final String recipientMobile;
  final String amount;
  final String date;
  final String status;

  const DisputeDetailsPage({
    super.key,
    required this.ticketId,
    required this.questionType,
    required this.recipientMobile,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DisputeDetailsPageState createState() => _DisputeDetailsPageState();
}

class _DisputeDetailsPageState extends State<DisputeDetailsPage> with TickerProviderStateMixin {
  int statusIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => statusIndex = 2); // Simulated animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dispute Details',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveChatPage(
                    amount: widget.amount,
                    date: widget.date,
                    questionType: widget.questionType,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Live Chat',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSection("Dispute Details", [
            detailRow("Ticket ID", widget.ticketId),
            detailRow("Question Type", widget.questionType),
          ]),
          const SizedBox(height: 16),
          buildSection("Transaction Details", [
            detailRow("Recipient Mobile", widget.recipientMobile),
            detailRow("Amount", widget.amount),
            detailRow("Transaction Date", widget.date),
            detailRow("Transaction Status", widget.status),
            detailRow("Transaction Channel", "Wallet Transfer"), // Dummy
            detailRow("Reference Number", "REF${widget.ticketId.substring(0, 6)}XYZ"), // Dummy
          ]),
          const SizedBox(height: 16),
          Text("Detailed Status", style: sectionTitleStyle),
          const SizedBox(height: 10),
          buildAnimatedStatusBar(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("We are confirming with MTN",
                style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 24),
          Text("Dispute Record", style: sectionTitleStyle),
          const SizedBox(height: 10),
          buildDisputeRecord(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF7063E4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            // Cancel request logic goes here
          },
          child: Text("Cancel Request",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: sectionTitleStyle),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: detailTitleStyle),
        Flexible(child: Text(value, style: detailValueStyle, textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget buildAnimatedStatusBar() {
    List<String> steps = [
      "Payment Successful",
      "Transaction Successful",
      "Confirming with MTN"
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (i) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: i <= statusIndex ? Color(0xFF7063E4) : Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 90,
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildDisputeRecord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        recordItem(
          title: "Recharge Successful",
          time: widget.date,
          body:
          "Your recharge of ${widget.amount} was successful. To check your airtime balance, kindly check your SMS inbox, dial *310#, or log into the MTN app. We will also check with MTN once again. If there's an update, you'll receive a push notification.",
        ),
        const SizedBox(height: 16),
        recordItem(
          title: "Submit",
          time: widget.date,
          body: "Your complaint has been received and is currently under review.",
        ),
      ],
    );
  }

  Widget recordItem({required String title, required String time, required String body}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.check_circle, color: Color(0xFF7063E4), size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    ]);
  }

  TextStyle get sectionTitleStyle => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle get detailTitleStyle => GoogleFonts.poppins(fontSize: 14, color: Colors.black87);
  TextStyle get detailValueStyle =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);
}




/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisputeDetailsPage extends StatefulWidget {
  final String ticketId;
  final String questionType;
  final String recipientMobile;
  final String amount;
  final String date;
  final String status;

  const DisputeDetailsPage({
    super.key,
    required this.ticketId,
    required this.questionType,
    required this.recipientMobile,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  _DisputeDetailsPageState createState() => _DisputeDetailsPageState();
}

class _DisputeDetailsPageState extends State<DisputeDetailsPage> with TickerProviderStateMixin {
  int statusIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => statusIndex = 2); // Simulated animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Dispute Details', style: GoogleFonts.poppins(fontSize: 18)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Live Chat',
                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500)),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSection("Dispute Details", [
            detailRow("Ticket ID", widget.ticketId),
            detailRow("Question Type", widget.questionType),
          ]),
          const SizedBox(height: 16),
          buildSection("Transaction Details", [
            detailRow("Recipient Mobile", widget.recipientMobile),
            detailRow("Amount", widget.amount),
            detailRow("Transaction Date", widget.date),
            detailRow("Transaction Status", widget.status),
            detailRow("Transaction Channel", "Wallet Transfer"), // Dummy
            detailRow("Reference Number", "REF${widget.ticketId.substring(0, 6)}XYZ"), // Dummy
          ]),
          const SizedBox(height: 16),
          Text("Detailed Status", style: sectionTitleStyle),
          const SizedBox(height: 10),
          buildAnimatedStatusBar(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("We are confirming with MTN",
                style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 24),
          Text("Dispute Record", style: sectionTitleStyle),
          const SizedBox(height: 10),
          buildDisputeRecord(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF7063E4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            // Cancel request logic goes here
          },
          child: Text("Cancel Request",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: sectionTitleStyle),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: detailTitleStyle),
        Flexible(child: Text(value, style: detailValueStyle, textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget buildAnimatedStatusBar() {
    List<String> steps = [
      "Payment Successful",
      "Transaction Successful",
      "Confirming with MTN"
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (i) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: i <= statusIndex ? Color(0xFF7063E4) : Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 90,
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildDisputeRecord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        recordItem(
          title: "Recharge Successful",
          time: widget.date,
          body:
          "Your recharge of ${widget.amount} was successful. To check your airtime balance, kindly check your SMS inbox, dial *310#, or log into the MTN app. We will also check with MTN once again. If there's an update, you'll receive a push notification.",
        ),
        const SizedBox(height: 16),
        recordItem(
          title: "Submit",
          time: widget.date,
          body: "Your complaint has been received and is currently under review.",
        ),
      ],
    );
  }

  Widget recordItem({required String title, required String time, required String body}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.check_circle, color: Color(0xFF7063E4), size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    ]);
  }

  TextStyle get sectionTitleStyle => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle get detailTitleStyle => GoogleFonts.poppins(fontSize: 14, color: Colors.black87);
  TextStyle get detailValueStyle =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);
}

 */











