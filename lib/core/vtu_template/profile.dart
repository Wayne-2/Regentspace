import 'verification.dart';
import 'package:flutter/material.dart';
import 'nextofkin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isVerified = false; // Tracks BVN status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 15),
          const Image(
            image: AssetImage("images/profileicon.png"),
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 10),
          const Text(
            'Julius Oladayo Ijidola',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1D3A70)),
          ),
          const SizedBox(height: 25),

          const LabelWithDescription(
            title: "Full Name",
            description: "Julius Oladayo Ijidola",
            descriptionColor: Color(0xFF1D3A70),
          ),
          const LabelWithDescription(
            title: "Address",
            description: "145, Lasd Street, Lagos",
            descriptionColor: Color(0xFF1D3A70),
          ),
          const LabelWithDescription(
            title: "Phone Number",
            description: "09012345678",
            descriptionColor: Color(0xFF1D3A70),
          ),
          const LabelWithDescription(
            title: "Email Address",
            description: "ijidolaj@gmail.com",
            descriptionColor: Color(0xFF1D3A70),
          ),

          // Identification Container
          GestureDetector(
            onTap: isVerified
                ? null
                : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerificationPage(),
                ),
              );

              // If verified, update state
              if (result == true) {
                setState(() => isVerified = true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 64,
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(75, 0, 0, 0),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Identification',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Color(0xFFF56C2A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVerified ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isVerified ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    // Show arrow only if NOT verified
                    if (!isVerified)
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1D3A70)),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}






/*
import 'package:chiefsolomonfirstwork/verification.dart';
import 'package:flutter/material.dart';
import 'package:chiefsolomonfirstwork/nextofkin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isVerified = false; // Tracks BVN status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 15),
          const Image(
            image: AssetImage("images/profileicon.png"),
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 10),
          const Text(
            'Julius Oladayo Ijidola',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1D3A70)),
          ),
          const SizedBox(height: 25),

          const LabelWithDescription(
            title: "Full Name",
            description: "Julius Oladayo Ijidola",
            descriptionColor: Color(0xFF1D3A70),
          ),
          const LabelWithDescription(
            title: "Address",
            description: "145, Lasd Street, Lagos",
            descriptionColor: Color(0xFF1D3A70),
          ),
          const LabelWithDescription(
            title: "Phone Number",
            description: "09012345678",
            descriptionColor: Color(0xFF1D3A70),
          ),
          const LabelWithDescription(
            title: "Email Address",
            description: "ijidolaj@gmail.com",
            descriptionColor: Color(0xFF1D3A70),
          ),

          // Identification Container
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerificationPage(),
                ),
              );

              // If verified, update state
              if (result == true) {
                setState(() => isVerified = true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 64,
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Identification',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Color(0xFFF56C2A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVerified ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isVerified ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1D3A70)),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

 */