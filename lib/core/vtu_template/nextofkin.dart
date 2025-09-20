import 'package:flutter/material.dart';

class Nextofkin extends StatefulWidget {
  const Nextofkin({super.key});
  @override
  State<Nextofkin> createState() => _NextofkinState();
}

class _NextofkinState extends State<Nextofkin> {
  String _selectedRelation = 'Father';
  final List<String> _relationOptions = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Spouse',
    'Guardian',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            'Next of Kin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Update Next of Kin",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1D3A70),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please enter your next of kin details",
                style: TextStyle(fontSize: 16, color: Color(0xFF1D3A70)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              const LabelWithDescription(
                title: "Full Name",
                description: "Samantha Zalora",
                descriptionColor: Color(0xFF1D3A70),
              ),
              SizedBox(height: 10),
              const LabelWithDescription(
                title: "Address",
                description: "145, Lasd Street, Lagos",
                descriptionColor: Color(0xFF1D3A70),
              ),
              SizedBox(height: 10),
              const LabelWithDescription(
                title: "Phone Number",
                description: "09012345678",
                descriptionColor: Color(0xFF1D3A70),
              ),
              SizedBox(height: 10),
              const LabelWithDescription(
                title: "Email Address",
                description: "samanthazaloraj@gmail.com",
                descriptionColor: Color(0xFF1D3A70),
              ),

              // Relationship Dropdown

              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(48, 0, 0, 0), // very faint shadow
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                    //border: Border.all(color: Color(0xFFE0E0E0)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedRelation,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      elevation: 2,
                      style: const TextStyle(
                        color: Color(0xFF1D3A70),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRelation = newValue;
                          });
                        }
                      },
                      items: _relationOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// LabelWithDescription Widget
class LabelWithDescription extends StatelessWidget {
  final String title;
  final String description;
  final Color? descriptionColor;

  const LabelWithDescription({
    super.key,
    required this.title,
    required this.description,
    this.descriptionColor,
  });

  static const Color _titleColor = Color(0xFFF56C2A); // Orange
  static const Color _defaultDescriptionColor = Color(0xFF1D3A70); // Navy Blue

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 64,
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(57, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: descriptionColor ?? _defaultDescriptionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



















