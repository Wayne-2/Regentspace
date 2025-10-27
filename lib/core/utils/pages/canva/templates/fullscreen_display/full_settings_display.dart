// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullSettingsDisplay extends StatelessWidget {
  const FullSettingsDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3), // ⬅ Horizontal screen padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileOptionNewTile(
                      title: 'Profile',
                      leading: Image.asset(
                        'assets/images/profile.png',
                        width: 20,
                        height: 20,
                      ),
                      onTap: () {
                        },
                    ),
      
                    SizedBox(height: 6),
      
                    ProfileOptionNewTile(
                      title: 'Linked Accounts',
                      leading: Image.asset(
                        'assets/images/linkedacct.png',
                        width: 20,
                        height:20,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 6),
      
                    ProfileOptionNewTile(
                      title: 'Referrals',
                      leading: Image.asset(
                        'assets/images/referrals.png',
                        width: 20,
                        height: 20,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 6),
      
                    ProfileOptionNewTile(
                      title: 'Security',
                      leading: Image.asset(
                        'assets/images/security.png',
                        width: 20,
                        height: 20,
                      ),
                      onTap: () {
                        },
                    ),
      
                    SizedBox(height: 6),
      
                    ProfileOptionNewTile(
                      title: 'About Us',
                      leading: Image.asset(
                        'assets/images/aboutus.png',
                        width: 20,
                        height: 20,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 6),
      
                    ProfileOptionNewTile(
                      title: 'FAQs',
                      leading: Image.asset(
                        'assets/images/FAQs.png',
                        width: 20,
                        height: 20,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 6),
      
                    ProfileOptionNewTile(
                      title: 'Log Out',
                      leading: Image.asset(
                        'assets/images/logout.png',
                        width: 20,
                        height: 20,
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


class ProfileOptionNewTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget leading;

  const ProfileOptionNewTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D3A70),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_sharp,
                  color: Color(0xFF1D3A70), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
