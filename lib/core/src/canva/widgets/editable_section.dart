import 'package:flutter/material.dart';
import 'package:newregentspace/core/demo_pages/utils/navigator.dart';

class EditableSection extends StatelessWidget {
  final TextEditingController textEditingController;
  final VoidCallback onPickImage;
  final VoidCallback onPickBgImage;
  final VoidCallback onPickAppNameColor;
  final VoidCallback onPickBackgroundColor;
  final VoidCallback onPickPrimaryTheme;
  final VoidCallback onPickHomeBgColor;
  final VoidCallback onAppNameChanged;
  final VoidCallback onPickIconThemeColor;
  final Color appNameColor;
  final Color myColor;
  final Color primaryapptheme;
  final Color homePagebgColor;
  final Color iconthemeColor;
  final String? selectedBgImagePath;

  const EditableSection({
    super.key,
    required this.textEditingController,
    required this.onPickImage,
    required this.onPickBgImage,
    required this.onPickAppNameColor,
    required this.onPickBackgroundColor,
    required this.onPickPrimaryTheme,
    required this.onPickHomeBgColor,
    required this.onAppNameChanged,
    required this.appNameColor,
    required this.myColor,
    required this.primaryapptheme,
    required this.homePagebgColor,
    required this.onPickIconThemeColor,
    required this.iconthemeColor,
    required this.selectedBgImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ListView(
        children: [
             Row(
               children: [
                 // Text input field
                 Expanded(
                   child: TextField(
                    controller: textEditingController,
                     decoration: InputDecoration(
                       hintText: 'Enter App Name',
                       hintStyle: TextStyle(fontSize: 12),
                       contentPadding:
                           const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                       ),
                       suffixIcon: IconButton(
                        onPressed: () => textEditingController.clear(),
                        icon: const Icon(Icons.clear, size: 12),
                      ),
                     ),
                   ),
                 ),
         
                 const SizedBox(width: 8),
         
                 // Add button
                 ElevatedButton(
                   onPressed: onAppNameChanged,
                   style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 124, 17, 173),
                     padding: const EdgeInsets.all(14),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                   ),
                   child: const Icon(Icons.add, size: 20, color:Colors.white),
                 ),
               ],
              ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap:onPickImage,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_photo_alternate,
                          color: Color.fromARGB(115, 7, 7, 7), size: 20),
                      const SizedBox(width: 6),
                      Text('Change app logo', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Icon(
                    Icons.add,
                    color: const Color.fromARGB(159, 39, 39, 39),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: onPickAppNameColor,
            child: Container(
              padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 228, 228),
                  borderRadius: BorderRadius.circular(10)
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select App-name color', style: TextStyle(fontSize: 12)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: appNameColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPickBackgroundColor,
            child: Container(
              padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 228, 228),
                  borderRadius: BorderRadius.circular(10)
                ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Launch page background', style: TextStyle(fontSize: 12)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: myColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ],
              ),
            ),
          ), 
          const SizedBox(height: 12),

          // Dashboard Image Picker
          const Text('Home page',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap:onPickBgImage,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_photo_alternate,
                          color: Color.fromARGB(115, 7, 7, 7), size: 20),
                      const SizedBox(width: 6),
                      Text('Change info-panel image', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Icon(
                    Icons.add,
                    color: const Color.fromARGB(159, 39, 39, 39),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap:onPickPrimaryTheme,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select primary color theme', style: TextStyle(fontSize: 12)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: primaryapptheme,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPickHomeBgColor,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select home background', style: TextStyle(fontSize: 12)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: homePagebgColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPickIconThemeColor,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 228, 228),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Icon color', style: TextStyle(fontSize: 12)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: iconthemeColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            MaterialButton(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Colors.blueGrey,
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> BottomNav(
                  appNameColor: appNameColor, 
                  myColor: myColor, 
                  primaryapptheme: primaryapptheme, 
                  homePagebgColor: homePagebgColor, 
                  iconthemeColor: iconthemeColor,
                  selectedBgImagePath: selectedBgImagePath,)));
              },
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
              child:Text("Run Demo", style: TextStyle(color:Colors.white, fontSize: 10)),
            ),
            MaterialButton(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Colors.grey,
              onPressed: (){},
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
              child:Text("Save Draft", style: TextStyle(color:Colors.white, fontSize: 10)),
            ),
            MaterialButton(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical:10),
              color: const Color.fromARGB(255, 68, 5, 150),
              onPressed: (){},
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
              child:Text("Publish app", style: TextStyle(color:Colors.white, fontSize: 10)),
            )
          ],)
        ],
      ),
    );
  }
}
