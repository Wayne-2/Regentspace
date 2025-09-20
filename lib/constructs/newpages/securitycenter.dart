import 'package:flutter/material.dart';

class SecurityCenterPage extends StatelessWidget {
  final List<Map<String, String>> securityTips = [
    {
      'image': 'assets/images/pic1.png',
      'title': 'Use Strong Passwords',
      'description': 'Create unique passwords for each account and avoid using personal information.',
    },
    {
      'image': 'assets/images/pic2.png',
      'title': 'Enable Two-Factor Authentication',
      'description': 'Add an extra layer of protection to secure your account.',
    },
  ];

  final List<Map<String, String>> securityGuides = [
    {
      'image': 'assets/images/pic1.png',
      'title': 'Account Recovery Guide',
      'description': 'Learn the steps to recover access if you’re locked out of your account.',
    },
    {
      'image': 'assets/images/pic2.png',
      'title': 'Recognizing Phishing Attacks',
      'description': 'Understand how to spot and avoid phishing emails and links.',
    },
  ];

  SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Center'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security Tips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: securityTips.map((tip) {
                return SecurityTipsCard(
                  image: tip['image']!,
                  title: tip['title']!,
                  description: tip['description']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Placeholder()),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Security Guides',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: securityGuides.map((guide) {
                return SecurityGuideCard(
                  image: guide['image']!,
                  title: guide['title']!,
                  description: guide['description']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Placeholder()),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityTipsCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onTap;

  const SecurityTipsCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          //margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              Image.asset(image, width: 28, height: 28, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(description,
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecurityGuideCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onTap;

  const SecurityGuideCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          //margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              Image.asset(image, width: 28, height: 28, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(description,
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
