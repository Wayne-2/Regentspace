import 'package:flutter/material.dart';

class OfficeAddressPage extends StatelessWidget {
  final List<Map<String, String>> offices = [
    {
      'title': 'ABUJA',
      'address': 'Uyk Hexahub Plaza, Balanga Crescent off Uke Street by Bolton White Hotel, opposite Hawthorne Suites, Garki 11, Abuja',
    },
    {
      'title': 'LAGOS, ALLEN IKEJA',
      'address': 'No 103 Mosesola House, Allen Road, Ikeja Lagos',
    },
    {
      'title': 'LAGOS, FESTAC',
      'address': 'Plot 3084, 24 Sky Castle Plaza, Festac Access Road, beside Santiago hotel, Festac Town, Lagos',
    },
    {
      'title': 'LAGOS, IKORODU',
      'address': 'No. 132B Lagos Road, Ikorodu Jumofak Bus Stop, Ikorodu, Lagos State',
    },
    {
      'title': 'ABEO KUTA',
      'address': 'Dolly House Opposite Laroy Hotel, Abiola Way',
    },
    {
      'title': 'IBADAN',
      'address': 'No. 93, MKO Abiola Way, adjacent Bond Mall, beside...',
    },
  ];

  OfficeAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Office address',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                'images/location.jpeg',
                fit: BoxFit.cover,
                height: 100,
                width: double.infinity,
              ),
              SizedBox(height: 20), // To leave space under the overlaying card
            ],
          ),
          Positioned.fill(
            top: 80, // Start the list just below the image, adjust as needed
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: offices.length,
              itemBuilder: (context, index) {
                final office = offices[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 6,
                    top: index == 0 ? 0 : 12, // No top padding on the first card
                  ),
                  child: LocationCard(
                    title: office['title']!,
                    address: office['address']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String title;
  final String address;

  const LocationCard({
    super.key,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          //const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(
              thickness: 0.5,
              color: Colors.grey.shade400,
              height: 1,
            ),
          ),
          Text(
            address,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}









/*
import 'package:flutter/material.dart';

class OfficeAddressPage extends StatelessWidget {
  final List<Map<String, String>> offices = [
    {
      'title': 'ABUJA',
      'address': 'Uyk Hexahub Plaza, Balanga Crescent off Uke Street by Bolton White Hotel, opposite Hawthorne Suites, Garki 11, Abuja',
    },
    {
      'title': 'LAGOS, ALLEN IKEJA',
      'address': 'No 103 Mosesola House, Allen Road, Ikeja Lagos',
    },
    {
      'title': 'LAGOS, FESTAC',
      'address': 'Plot 3084, 24 Sky Castle Plaza, Festac Access Road, beside Santiago hotel, Festac Town, Lagos',
    },
    {
      'title': 'LAGOS, IKORODU',
      'address': 'No. 132B Lagos Road, Ikorodu Jumofak Bus Stop, Ikorodu, Lagos State',
    },
    {
      'title': 'ABEO KUTA',
      'address': 'Dolly House Opposite Laroy Hotel, Abiola Way',
    },
    {
      'title': 'IBADAN',
      'address': 'No. 93, MKO Abiola Way, adjacent Bond Mall, beside...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Office address',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Replace with your header image
          Image.asset(
            'images/location.jpeg',
            fit: BoxFit.cover,
            height: 100,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: offices.length,
              itemBuilder: (context, index) {
                final office = offices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LocationCard(
                    title: office['title']!,
                    address: office['address']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String title;
  final String address;

  const LocationCard({
    Key? key,
    required this.title,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          //const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(
              thickness: 0.5,
              color: Colors.grey.shade400,
              height: 1,
            ),
          ),
          Text(
            address,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

 */