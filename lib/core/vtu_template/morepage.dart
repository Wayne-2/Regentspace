import 'profile.dart';
import 'security.dart';
import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       /* leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),

        */
        title: const Text('More', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // ⬅ Horizontal screen padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileOptionTile(
                title: 'Profile',
                leading: Image.asset(
                  'images/profile.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()));},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Linked Accounts',
                leading: Image.asset(
                  'images/linkedacct.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Saved Cards',
                leading: Image.asset(
                  'images/savedcards.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Referrals',
                leading: Image.asset(
                  'images/referrals.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Security',
                leading: Image.asset(
                  'images/security.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecurityPage()));},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Support',
                leading: Image.asset(
                  'images/support.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'About Us',
                leading: Image.asset(
                  'images/aboutus.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'FAQs',
                leading: Image.asset(
                  'images/FAQs.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Privacy Policy',
                leading: Image.asset(
                  'images/privacypolicy.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

              SizedBox(height: 10),

              ProfileOptionTile(
                title: 'Log Out',
                leading: Image.asset(
                  'images/logout.png',
                  width: 24,
                  height: 24,
                ),
                onTap: () {},
              ),

            ],
          ),
        ),
      ),

    );
  }
}


class ProfileOptionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget leading;

  const ProfileOptionTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      //color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D3A70),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_sharp,
                color: Color(0xFF1D3A70),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
