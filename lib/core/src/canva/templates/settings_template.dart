import 'package:flutter/cupertino.dart';
import 'package:newregentspace/core/src/canva/canva.dart';
import 'package:newregentspace/core/src/canva/widgets/profile_option_new_tile.dart';

class SettingsTemplate extends StatelessWidget {
  const SettingsTemplate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {
                        },
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'Linked Accounts',
                      leading: Image.asset(
                        'assets/images/linkedacct.png',
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'Referrals',
                      leading: Image.asset(
                        'assets/images/referrals.png',
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'Security',
                      leading: Image.asset(
                        'assets/images/security.png',
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {
                        },
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'Support',
                      leading: Image.asset(
                        'images/support.png',
                        width: 10,
                        height: 10,                ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'About Us',
                      leading: Image.asset(
                        'assets/images/aboutus.png',
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'FAQs',
                      leading: Image.asset(
                        'assets/images/FAQs.png',
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'Privacy Policy',
                      leading: Image.asset(
                        'images/privacypolicy.png',
                        width: 10,
                        height: 10,
                      ),
                      onTap: () {},
                    ),
      
                    SizedBox(height: 3),
      
                    ProfileOptionNewTile(
                      title: 'Log Out',
                      leading: Image.asset(
                        'assets/images/logout.png',
                        width: 10,
                        height: 10,
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
