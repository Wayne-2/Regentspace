import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool isBvnVerified = false;
  bool isEnteringBvn = false;
  final TextEditingController _bvnController = TextEditingController();

  bool get isFormValid => _bvnController.text.length == 11;

  @override
  void initState() {
    super.initState();
    _bvnController.addListener(() {
      setState(() {}); // Refresh UI when typing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (isEnteringBvn) {
              setState(() => isEnteringBvn = false); // Go back to status view
            } else {
              Navigator.pop(context); // Exit page
            }
          },
        ),
        title: const Text(
          "Verification",
          style: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isEnteringBvn
            ? _buildBvnEntryView()
            : _buildVerificationStatusView(),
      ),
    );
  }

  Widget _buildVerificationStatusView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Verify Your Identity",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1D3A70)),
        ),
        const SizedBox(height: 10),
        const Text(
          "To remove all limits on your account, we need to verify your identity.",
          style: TextStyle(fontSize: 16, color: Color(0xFF1D3A70)),
        ),


        const SizedBox(height: 20),



        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "BVN",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isBvnVerified ? "Verified" : "Not Verified",
                  style: TextStyle(
                      color: isBvnVerified ? Colors.green : Colors.red,
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
                trailing: Icon(
                  isBvnVerified ? Icons.check_circle : Icons.info,
                  color: isBvnVerified ? Colors.green : Colors.red,
                ),
                onTap: () {
                  if (!isBvnVerified) {
                    setState(() => isEnteringBvn = true);
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }


  Widget _buildBvnEntryView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Text(
                  "Verify Your BVN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1D3A70)),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your Bank Verification Number to complete your account setup",
                  style: TextStyle(color: Color(0xFF1D3A70), fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Enter your BVN',
              style: TextStyle(fontSize: 14, color: Color(0xFF979797)),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _bvnController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: "00000000000",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFFC4C4C4)),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isFormValid
                    ? () {
                  setState(() {
                    isBvnVerified = true;
                    isEnteringBvn = false;
                    _bvnController.clear();
                  });
                  // Pop and return verification success to previous page
                  Navigator.pop(context, true);
                }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFormValid
                        ? const Color(0xFF7063E4)
                        : const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      color: isFormValid
                          ? Colors.white
                          : const Color.fromARGB(131, 255, 255, 255),
                    ),
                  ),
                ),
              ),

            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}





