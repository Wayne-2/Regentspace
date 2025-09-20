import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 253, 253, 253),
        appBar: AppBar(
          backgroundColor:  Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Updates",
            style: GoogleFonts.sora(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),

                Image(
                  image: AssetImage("assets/images/noupdate.png"),
                  width: 136,
                  height: 136,
                  opacity: AlwaysStoppedAnimation<double>(0.5),
                ),
                
                SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'No available update for the mean while, go back to main page',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8C8C8C),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}

