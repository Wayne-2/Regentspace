import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveChatPage extends StatefulWidget {
  final String amount;
  final String date;
  final String questionType;

  const LiveChatPage({
    super.key,
    required this.amount,
    required this.date,
    required this.questionType,
  });

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  final TextEditingController _controller = TextEditingController();

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    // You can handle sending logic here.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Message sent"),
      duration: Duration(seconds: 1),
    ));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Chat Support', style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Describe your issue here...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          //const SizedBox(height: 12),
          buildDetailsFooter(),


          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7063E4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Send", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),

          SizedBox(height: 50)

        ],
      ),
    );
  }

  Widget buildDetailsFooter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Transaction Summary", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          infoRow("Amount", widget.amount),
          infoRow("Date", widget.date),
          infoRow("Question Type", widget.questionType),
        ]),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          Flexible(
            child: Text(value,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
