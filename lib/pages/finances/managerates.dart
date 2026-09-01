import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ManageRatesPage extends StatefulWidget {
  const ManageRatesPage({super.key});

  @override
  State<ManageRatesPage> createState() => _ManageRatesPageState();
}

class _ManageRatesPageState extends State<ManageRatesPage> {
  final Color primaryColor = const Color.fromRGBO(74, 0, 99, 1);

  final Map<String, double> airtimeRates = {
    'MTN': 98.0,
    'GLO': 97.0,
    'Airtel': 96.0,
    '9mobile': 95.0,
  };

  final Map<String, double> dataRates = {
    'MTN': 280,
    'GLO': 270,
    'Airtel': 285,
    '9mobile': 300,
  };

  void _editRateDialog(String type, String network, double currentRate) {
    final controller = TextEditingController(text: currentRate.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Edit $network $type Rate",
            style: TextStyle(fontFamily: 'DMSans', 
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: type == "Airtime" ? "Discount (%)" : "₦ per GB",
              labelStyle: TextStyle(fontFamily: 'DMSans', color: Colors.grey[700]),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.3),
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontFamily: 'DMSans', color: Colors.grey)),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final newRate = double.tryParse(controller.text);
                  if (newRate != null) {
                    setState(() {
                      if (type == "Airtime") {
                        airtimeRates[network] = newRate;
                      } else {
                        dataRates[network] = newRate;
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(fontFamily: 'DMSans', color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateCard(String title, Map<String, double> rates, String type) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor)),
            const Divider(height: 20, thickness: 0.6),
            ...rates.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: TextStyle(fontFamily: 'DMSans', 
                            fontWeight: FontWeight.w500, fontSize: 16)),
                    Row(
                      children: [
                        Text(
                          type == "Airtime"
                              ? "${entry.value.toStringAsFixed(1)}%"
                              : "₦${entry.value.toStringAsFixed(0)}",
                          style: TextStyle(fontFamily: 'DMSans', 
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () =>
                              _editRateDialog(type, entry.key, entry.value),
                          child: Icon(
                            CupertinoIcons.pencil_circle,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fb),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Manage Rates",
           style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Adjust your data and airtime rates to suit your business preferences.",
              style: TextStyle(fontFamily: 'DMSans', 
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildRateCard("Airtime Rates", airtimeRates, "Airtime"),
            _buildRateCard("Data Rates", dataRates, "Data"),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Rates saved successfully ✅")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                  label: Text(
                    "Save Changes",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
