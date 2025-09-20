// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';

class BuyAirtimePage extends StatefulWidget {
  const BuyAirtimePage({super.key});


  @override
  State<BuyAirtimePage> createState() => _BuyAirtimePageState();
}

class _BuyAirtimePageState extends State<BuyAirtimePage> {
  String? _selectedNetwork;
  String? _selectedDataPlan;
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool get isFormValid {
    return _mobileNumberController.text.trim().isNotEmpty &&
        (_selectedDataPlan != null || _amountController.text.trim().isNotEmpty);
  }




  final List<Map<String, String>> _networks = [
    {'name': 'MTN', 'imagePath': 'images/mtn.png'},
    {'name': 'GLO', 'imagePath': 'images/glo.png'},
    {'name': 'Airtel', 'imagePath': 'images/airtel.png'},
    {'name': '9Mobile', 'imagePath': 'images/9mobile.png'},
  ];

  final List<String> _dataPlans = [
    '500 MB (30 days) @ ₦150.00'
    '0.00 MB/s',
    '100 MB for N50',
    '500 MB for N100',
    '1 GB for N200'
  ];

  @override
  void initState() {
    super.initState();
    _mobileNumberController.addListener(_onFormChange);
    _amountController.addListener(_onFormChange);
  }

  void _onFormChange() {
    setState(() {}); // Rebuilds UI to reflect button state
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buy Airtime', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Network',
              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            /// Network Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              //mainAxisAlignment: MainAxisAlignment.start,
              children: _networks.map((network) {
                final name = network['name']!;
                final imagePath = network['imagePath']!;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedNetwork = name;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedNetwork == name
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(name),
                    ],
                  ),
                );
              }).toList(),
            ),






            //ENTER AMOUNT
            const SizedBox(height: 24),
            const Text(
              'Enter Amount',
              style: TextStyle(fontSize: 14, color: Color(0xFF979797)),
            ),
            const SizedBox(height: 10),
           /* HybridAmountInput(
              controller: _amountController,
              suggestions: [
                '500 MB (30 days) @ ₦150.00'
                '100',
                '200',
                '500',
                '1000',
                '1500',
              ],
            ),

            */
           Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFC4C4C4)), // Visible light gray border
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: InputBorder.none, // Keeps the outer container border clean
                ),
                dropdownColor: Colors.white,
                value: _selectedDataPlan,
                hint: const Text(
                  '₦ 0.00',
                  style: TextStyle(
                    color: Color(0xFFC4C4C4),
                    fontSize: 16,
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items: _dataPlans.map((plan) {
                  return DropdownMenuItem(
                    value: plan,
                    child: Text(plan, style: TextStyle(color: Color(0xFF1D3A70), fontSize: 16, fontWeight: FontWeight.w500),),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDataPlan = newValue;
                  });
                },
              ),
            ),






            //ENTER MOBILE NUMBER
            const SizedBox(height: 24),
            const Text(
              'Enter Mobile Number',
              style: TextStyle(fontSize: 14, color: Color(0xFF979797) ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(
                color: Color(0xFF1D3A70),      // Change text color
                fontSize: 16,
                fontWeight: FontWeight.w500,
               // letterSpacing: 1.0,
              ),
              controller: _mobileNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFF6F8FB),
                //hintText: 'Enter Mobile Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
            ),


            const SizedBox(height: 32),



            //NEXT

            GestureDetector(
              onTap: isFormValid ? () {

                print('Proceeding with:');
                print('Mobile: ${_mobileNumberController.text}');
                print('Amount: ${_selectedDataPlan ?? _amountController.text}');
              } : null,
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFormValid ? const Color(0xFF7063E4) : const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    color: isFormValid ? Colors.white : const Color.fromARGB(125, 255, 255, 255),
                  ),
                ),
              ),
            ),

            /*
            Container(
              width: double.infinity, // Make it stretch to full width
              height: 50, // Match height of other inputs
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Next",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

             */

          ],
        ),
      ),
    );
  }
}




class NetworkIcon extends StatelessWidget {
  final String network;
  final bool isSelected;
  final VoidCallback onTap;

  const NetworkIcon({
    super.key,
    required this.network,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 28,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  'assets/images/${network.toLowerCase()}.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(network),
        ],
      ),
    );
  }
}





class HybridAmountInput extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;

  const HybridAmountInput({
    super.key,
    required this.controller,
    required this.suggestions,
  });

  @override
  State<HybridAmountInput> createState() => _HybridAmountInputState();
}

class _HybridAmountInputState extends State<HybridAmountInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC4C4C4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '₦ 0.00',
                hintStyle: TextStyle(
                  color: Color(0xFFC4C4C4),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          Container(
            height: 55,
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (value) {
                widget.controller.text = value;
              },
              itemBuilder: (context) => widget.suggestions
                  .map((item) => PopupMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
