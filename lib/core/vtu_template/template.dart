import 'package:flutter/material.dart';

class TemplateGalleryPage extends StatelessWidget {
  const TemplateGalleryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28),
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 20),
                    Text(
                      'Templates',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.more_vert),
                  ],
                ),
          
                SizedBox(height: 16),
          
                // Search bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Text(
                        "Search Templates",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
          
                SizedBox(height: 16),
          
                // Template Layout
          
                // Row 1 - Two small images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    templateBox("images/short1.png", 156, 147),
                    templateBox("images/short2.png", 156, 147),
                  ],
                ),
          
                SizedBox(height: 12),
          
                // Row 2 - One wide image
                Center(
                  child: templateBox("images/long.png", 335, 147),
                ),
          
                SizedBox(height: 12),
          
                // Row 3 - Two small images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    templateBox("images/short3.png", 156, 147),
                    templateBox("images/short4.png", 156, 147),
                  ],
                ),
          
                SizedBox(height: 12),
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    templateBox("images/short5.png", 156, 147),
                    templateBox("images/short6.png", 156, 147),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget templateBox(String imagePath, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}











/*import 'package:flutter/material.dart';

class TemplateGalleryPage extends StatelessWidget {
  const TemplateGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios_new, size: 20),
                  Text(
                    'Templates',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.more_vert),
                ],
              ),

              SizedBox(height: 16),

              // Search bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    SizedBox(width: 10),
                    Text(
                      "Search Templates",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Template grid
              Expanded(
                child: GridView.builder(
                  itemCount: 12, // You can change this as needed
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage("assets/images/template_${index + 1}.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
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
