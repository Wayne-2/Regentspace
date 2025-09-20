import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newregentspace/constructs/newpages/customersupport.dart';
import 'package:newregentspace/core/vtu_template/notificationpage.dart';
import 'package:newregentspace/core/vtu_template/userprofile.dart';

class RegentSettings extends StatelessWidget {
  const RegentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // ⬅ Horizontal screen padding
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25),
                 Text(
                      "Settings",
                      style: GoogleFonts.sora(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 20),
                ProfileOptionTile(
                  title: 'Personal Details',
                  leading: Icon(Icons.person_rounded),
                  onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=> Userprofilepage()));      
                  }
                ),
            
                SizedBox(height: 10),
            
                ProfileOptionTile(
                  title: 'Notifications',
                  leading: Icon(Icons.notification_add_rounded),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Notificationpage()));
                    
                  },
                ),
            
                SizedBox(height: 10),
            
                ProfileOptionTile(
                  title: 'Support',
                  leading: Icon(Icons.support_agent_rounded),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> SupportPage()));
                  },
                ),
            
                SizedBox(height: 10),
            
                ProfileOptionTile(
                  title: 'Privacy Policy & Terms',
                  leading: Icon(Icons.privacy_tip_rounded),
                  onTap: () {},
                ),
            
                SizedBox(height: 10),
            
                ProfileOptionTile(
                  title: 'Sign Out',
                  leading: Icon(Icons.logout_rounded),
                  onTap: () {},
                ),
            
            
              ],
            ),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033525),
                  ),
                ),
              ),
              /*const Icon(
                Icons.arrow_forward_ios_sharp,
                color: Color(0xFF1D3A70),
                size: 20,
              ),

               */
            ],
          ),
        ),
      ),
    );
  }
}
