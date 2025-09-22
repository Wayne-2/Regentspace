import 'package:flutter/material.dart';

class Bankaccount extends StatefulWidget {
  const Bankaccount({super.key});
  @override
  State<Bankaccount> createState() => BankaccountState();
}

class BankaccountState extends State<Bankaccount> {
    

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
            'Bank Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          Center(child: Image(image: AssetImage('images/bankacct.png'), height: 182, width: 182,)),
          SizedBox(height: 15),
          Text('No Bank Added!!!', style: TextStyle(fontSize: 14, color: Color(0xFF979797), fontWeight: FontWeight.w500),),
          SizedBox(height: 15),
          Text('Looks like you haven’t added any bank', style: TextStyle(fontSize: 16, color: Color(0xFF7063E4), fontWeight: FontWeight.w500),),
          Text('to your regentspace account yet', style: TextStyle(fontSize: 16, color: Color(0xFF7063E4), fontWeight: FontWeight.w500),),

          SizedBox(height: 70),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7063E4),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              onPressed: () {
                Navigator.of(context).pop();
                },


              child: Text(
                'Add Bank',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}