// ignore_for_file: deprecated_member_use

import 'transactiondetails.dart';
import 'package:flutter/material.dart';

class BuyPage extends StatefulWidget {
  final String pageTitle;
  final String planLabel;
  final String planHint;
  final String mobileLabel;
  final String mobileHint;
  final List<String> plans;
  final String purchaseType; // "Airtime" or "Data"


  const BuyPage({
     super.key,
    required this.pageTitle,
    required this.planLabel,
    required this.planHint,
    required this.mobileLabel,
    required this.mobileHint,
    required this.plans,
    required this.purchaseType,
  }) ;




  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {



  String? _selectedNetwork;
  String? _selectedPlan;
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool get isFormValid {
    return _mobileNumberController.text.trim().isNotEmpty &&
        (_selectedPlan != null || _amountController.text.trim().isNotEmpty);
  }

  final List<Map<String, String>> _networks = [
    {'name': 'MTN', 'imagePath': 'images/mtn.png'},
    {'name': 'GLO', 'imagePath': 'images/glo.png'},
    {'name': 'Airtel', 'imagePath': 'images/airtel.png'},
    {'name': '9Mobile', 'imagePath': 'images/9mobile.png'},
  ];

  @override
  void initState() {
    super.initState();
    _mobileNumberController.addListener(_onFormChange);
    _amountController.addListener(_onFormChange);
  }

  void _onFormChange() => setState(() {});

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
        title: Text(widget.pageTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _networks.map((network) {
                final name = network['name']!;
                final imagePath = network['imagePath']!;
                return GestureDetector(
                  onTap: () => setState(() => _selectedNetwork = name),
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
                            child: Image.asset(imagePath, fit: BoxFit.contain),
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
            const SizedBox(height: 24),
            Text(
              widget.planLabel,
              style: const TextStyle(fontSize: 14, color: Color(0xFF979797)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC4C4C4)),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(border: InputBorder.none),
                dropdownColor: Colors.white,
                value: _selectedPlan,
                hint: Text(
                  widget.planHint,
                  style: const TextStyle(
                    color: Color(0xFFC4C4C4),
                    fontSize: 16,
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items: widget.plans.map((plan) {
                  return DropdownMenuItem(
                    value: plan,
                    child: Text(
                      plan,
                      style: const TextStyle(
                          color: Color(0xFF1D3A70),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPlan = value),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.mobileLabel,
              style: const TextStyle(fontSize: 14, color: Color(0xFF979797)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(
                color: Color(0xFF1D3A70),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              controller: _mobileNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF6F8FB),
                hintText: widget.mobileHint,
                hintStyle: const TextStyle(color: Color(0xFFC4C4C4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              /*onTap: isFormValid
                  ? () {
                print('Proceeding with:');
                print('Network: $_selectedNetwork');
                print('Plan: $_selectedPlan');
                print('Mobile: ${_mobileNumberController.text}');
              }
                  : null,

               */
              onTap: isFormValid
                  ? () => _showSummaryDrawer(
                context,
                network: _selectedNetwork ?? '',
                plan: _selectedPlan ?? _amountController.text,
                mobile: _mobileNumberController.text,
                purchaseType: widget.purchaseType,
              )
                  : null,

              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFormValid
                      ? const Color(0xFF7063E4)
                      : const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    color: isFormValid
                        ? Colors.white
                        : const Color.fromARGB(125, 255, 255, 255)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



void _showSummaryDrawer(
    BuildContext parentContext, {
      required String network,
      required String plan,
      required String mobile,
      required String purchaseType,
    }) {
  // Extract numeric value for total
  final RegExp priceRegex = RegExp(r'₦\s?(\d+)');
  final match = priceRegex.firstMatch(plan);
  final amount = match != null ? '₦ ${match.group(1)}' : '₦ 0';


  showModalBottomSheet(
    context: parentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        //height: MediaQuery.of(context).size.height * 0.45, // 45% of screen height
        height: 364,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          //mainAxisSize: MainAxisSize.min,    //This autosizes the drawer
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3A70)
                ),
              ),
            ),
            const SizedBox(height: 35),
            _summaryRow('$network $purchaseType Purchase', plan.split(' ').first, Color(0xFFF56C2A)),
            const SizedBox(height: 30),
            _summaryRow('Total', amount, Color(0xFFF56C2A)),
            const SizedBox(height: 30),
            _summaryRow('Mobile Number', mobile, Color(0xFFF56C2A)),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7063E4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                onPressed: () {
                    Navigator.pop(context); // Close bottom sheet first

                    Future.delayed(const Duration(milliseconds: 300), () {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailsPage(
                            transactionId: '#${DateTime.now().millisecondsSinceEpoch}',
                            date: '20 Mar 2021 12:52 pm',
                            recipient: 'Mobile: $mobile',
                            type: '$purchaseType Purchase',
                            amount: amount,
                            fee: '₦0.00',
                            description: '$network $plan',
                            total: amount,
                          ),
                        ),
                      );
                    });
                  },

                child: Text(
                  'Pay $amount',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      );
    },
  );
}

Widget _summaryRow(String title, String value, Color valueColor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1D3A70)),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    ],
  );
}
