import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => SecurityPageState();
}

class SecurityPageState extends State<SecurityPage> {

  bool _isBiometricEnabled = false;

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
              'Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // ⬅ Horizontal screen padding
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      SecurityTile(
                        title: 'Biometrics Login',
                        leading: Image.asset(
                          'images/fingerprint.png',
                          width: 20,
                          height: 20,
                        ),
                        trailing: Switch(
                          value: _isBiometricEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isBiometricEnabled = value;
                            });
                          },
                          // ignore: deprecated_member_use
                          activeColor: const Color(0xFF7063E4),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                        onTap: () {}, // optional: could toggle on tap too
                      ),
                      /*SecurityTile(
                        title: 'Biometrics Login',
                        leading: Image.asset(
                          'images/fingerprint.png',
                          width: 24,
                          height: 24,
                        ),
                        onTap: () {},
                      ),

                       */

                      SizedBox(height: 10),

                      SecurityTile(
                        title: 'Change Password',
                        leading: Image.asset(
                          'images/lock.png',
                          width: 24,
                          height: 24,
                        ),
                        onTap: () {},
                      ),

                      SizedBox(height: 10),

                      SecurityTile(
                        title: 'Change PIN',
                        leading: Image.asset(
                          'images/Vector.png',
                          width: 35.55,
                          height: 33.88,
                        ),
                        onTap: () {},
                      ),
                    ])
            )
        )

    );
  }
}









class SecurityTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget leading;
  final Widget? trailing;

  const SecurityTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.leading,
    this.trailing,
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
          height: 86,
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
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}


/*

class SecurityTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget leading;

  const SecurityTile({
    Key? key,
    required this.title,
    required this.onTap,
    required this.leading,
  }) : super(key: key);

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
          height: 86,
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

            ],
          ),
        ),
      ),
    );
  }
}


 */