import 'transactiondetails.dart';
import 'package:flutter/material.dart';

class BuyUtilityPage extends StatelessWidget {
  final String title;
  final String transactionType;

  const BuyUtilityPage({
    super.key,
    required this.title,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElectricityForm(transactionType: transactionType),
      ),
    );
  }
}

class ElectricityForm extends StatefulWidget {
  final String transactionType;

  const ElectricityForm({super.key, required this.transactionType});

  @override
  State<ElectricityForm> createState() => _ElectricityFormState();
}

class _ElectricityFormState extends State<ElectricityForm> {
  String? selectedDisco;
  String? selectedMeterType;
  final TextEditingController meterNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool get isFormComplete {
    return selectedDisco != null &&
        selectedMeterType != null &&
        meterNumberController.text.isNotEmpty &&
        amountController.text.isNotEmpty;
  }

  void updateState() => setState(() {});

  @override
  void initState() {
    super.initState();
    meterNumberController.addListener(updateState);
    amountController.addListener(updateState);
  }

  @override
  void dispose() {
    meterNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Widget _summaryRow(String title, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D3A70),
          ),
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

  void _showSummaryDrawer(
      BuildContext parentContext, {
        required String disco,
        required String amount,
        required String meterNumber,
        required String customerName,
      }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 364,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3A70),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                _summaryRow(disco, '₦ $amount', const Color(0xFFF56C2A)),
                const SizedBox(height: 20),
                _summaryRow('Meter Number', meterNumber, const Color(0xFFF56C2A)),
                const SizedBox(height: 20),
                _summaryRow('Customer Name', customerName, const Color(0xFFF56C2A)),
                const SizedBox(height: 20),
                _summaryRow('Total', '₦ $amount', const Color(0xFFF56C2A)),
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
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TransactionDetailsPage(
                              transactionId:
                              '#${DateTime.now().millisecondsSinceEpoch}',
                              date: '20 Mar 2021 12:52 pm',
                              recipient: customerName,
                              type: 'Electricity Purchase',
                              amount: amount,
                              fee: '₦0.00',
                              description: '$disco - Meter: $meterNumber',
                              total: amount,
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      'Pay ₦ $amount',
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isElectricity =
        widget.transactionType.toLowerCase() == 'electricity';

    return Column(
      children: [
        LabeledDropdownField(
          label: isElectricity ? 'Select Disco' : 'Select Operator',
          hint: isElectricity ? 'Select Disco' : 'Select Operator',
          value: selectedDisco,
          items: (isElectricity
              ? ['Ibadan Electric - IBEDC', 'Eko Electric - EKEDC', 'Abuja Electric - AEDC']
              : ['DStv', 'GOtv', 'Startimes'])
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => selectedDisco = value),
        ),
        const SizedBox(height: 16),
        LabeledDropdownField(
          label: isElectricity ? 'Choose Meter Type' : 'Select Package',
          hint: isElectricity ? 'Meter Type' : 'Cable Package',
          value: selectedMeterType,
          items: (isElectricity ? ['Prepaid', 'Postpaid'] : ['Basic', 'Standard', 'Premium'])
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => selectedMeterType = value),
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: isElectricity ? 'Enter Meter Number' : 'Card Number',
          hint: isElectricity ? 'Meter Number' : 'Smart Card Number',
          controller: meterNumberController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Enter Amount',
          hint: '₦ 0.00',
          controller: amountController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isFormComplete
                ? () {
              _showSummaryDrawer(
                context,
                disco: selectedDisco!,
                amount: amountController.text,
                meterNumber: meterNumberController.text,
                customerName: 'John Doe',
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor:
              isFormComplete ? const Color(0xFF7063E4) : Colors.white,
              foregroundColor:
              isFormComplete ? const Color(0xFFDADADA) : Colors.white,
              elevation: isFormComplete ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Next"),
          ),
        ),
      ],
    );
  }
}

// ✅ Extracted to global scope — not inside _ElectricityFormState
class LabeledDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const LabeledDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(
                hint,
                style: const TextStyle(
                    color: Color(0xFF979797),
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              style: const TextStyle(
                  color: Color(0xFF1D3A70),
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconEnabledColor: const Color(0xFF1D3A70),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            style: const TextStyle(
                color: Color(0xFF1D3A70),
                fontWeight: FontWeight.w500,
                fontSize: 16),
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFF979797),
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }
}


















/*
import 'package:chiefsolomonfirstwork/transactiondetails.dart';
import 'package:flutter/material.dart';

class BuyUtilityPage extends StatelessWidget {
  final String title;
  final String transactionType;

  const BuyUtilityPage({
    Key? key,
    required this.title,
    required this.transactionType,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buy Electricity', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElectricityForm(transactionType: transactionType),
      ),
    );
  }
}

class ElectricityForm extends StatefulWidget {
  final String transactionType;

  const ElectricityForm({Key? key, required this.transactionType}) : super(key: key);

  @override
  State<ElectricityForm> createState() => _ElectricityFormState();
}


class _ElectricityFormState extends State<ElectricityForm> {
  String? selectedDisco;
  String? selectedMeterType;
  final TextEditingController meterNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();




  Widget _summaryRow(String title, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D3A70),
          ),
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



  void _showSummaryDrawer(
      BuildContext parentContext, {
        required String disco,
        required String amount,
        required String meterNumber,
        required String customerName,
      }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 364,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3A70),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                _summaryRow(disco, '₦ $amount', const Color(0xFFF56C2A)),
                const SizedBox(height: 20),
                _summaryRow('Meter Number', meterNumber, const Color(0xFFF56C2A)),
                const SizedBox(height: 20),
                _summaryRow('Customer Name', customerName, const Color(0xFFF56C2A)),
                const SizedBox(height: 20),
                _summaryRow('Total', '₦ $amount', const Color(0xFFF56C2A)),
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
                      Navigator.of(context).pop(); // Close bottom sheet first

                      // Delay before pushing to allow bottom sheet to fully close
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.of(parentContext).push(
                          MaterialPageRoute(
                            builder: (_) => TransactionDetailsPage(
                              transactionId: '#${DateTime.now().millisecondsSinceEpoch}',
                              date: '20 Mar 2021 12:52 pm',
                              recipient: customerName,
                              type: 'Electricity Purchase',
                              amount: amount,
                              fee: '₦0.00',
                              description: '$disco - Meter: $meterNumber',
                              total: amount,
                            ),
                          ),
                        );
                      });
                    },



                    child: Text(
                      'Pay ₦ $amount',
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
          ),
        );
      },
    );
  }






  bool get isFormComplete {
  return selectedDisco != null &&
      selectedMeterType != null &&
      meterNumberController.text.isNotEmpty &&
      amountController.text.isNotEmpty;
}

  void updateState() => setState(() {});

  @override
  void initState() {
    super.initState();
    meterNumberController.addListener(updateState);
    amountController.addListener(updateState);
  }

  @override
  void dispose() {
    meterNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabeledDropdownField(
          label: 'Select Disco',
          hint: 'Select Disco',
          value: selectedDisco,
          items: const [
            'Ibadan Electric - IBEDC',
            'Eko Electric - EKEDC',
            'Abuja Electric - AEDC',
          ],
          onChanged: (value) {
            setState(() => selectedDisco = value);
          },
        ),
        const SizedBox(height: 16),
        LabeledDropdownField(
          label: 'Choose Meter Type',
          hint: 'Meter Type',
          value: selectedMeterType,
          items: const [
            'Prepaid',
            'Postpaid',
          ],
          onChanged: (value) {
            setState(() => selectedMeterType = value);
          },
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Enter Meter Number',
          hint: 'Meter Number',
          controller: meterNumberController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Enter Amount',
          hint: '₦ 0.00',
          controller: amountController,
          keyboardType: TextInputType.number,
        ),


        const SizedBox(height: 32),

        //NEXT BUTTON
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isFormComplete
                ? () {
              _showSummaryDrawer(
                context,
                disco: selectedDisco!,
                amount: amountController.text,
                meterNumber: meterNumberController.text,
                customerName: 'John Doe', // You can replace this with real name lookup later
              );
            }
                : null,

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isFormComplete
                  ? Color(0xFF7063E4)
                  : Colors.white,
              foregroundColor: isFormComplete
                  ? Color(0xFFDADADA)
                  : Colors.white,
              elevation: isFormComplete ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Next"),
          ),
        ),
      ],
    );
  }
}


class LabeledDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LabeledDropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),

        const SizedBox(height: 6),


        //DROPDOWN SECTION
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            //border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(hint, style: TextStyle(color: Color(0xFF979797), fontSize: 14, fontWeight: FontWeight.normal),),
              style: TextStyle(color: Color(0xFF1D3A70), fontWeight: FontWeight.w500, fontSize: 16),
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconEnabledColor: Color(0xFF1D3A70),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const LabeledTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),


        //TEXTFIELD SECTION
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            //border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            style: TextStyle(color: Color(0xFF1D3A70), fontWeight: FontWeight.w500, fontSize: 16),
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Color(0xFF979797), fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }
}

 */