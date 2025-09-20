import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final String transactionId;
  final String date;
  final String recipient;
  final String type;
  final String amount;
  final String fee;
  final String description;
  final String total;

  const TransactionDetailsPage({
    super.key,
    required this.transactionId,
    required this.date,
    required this.recipient,
    required this.type,
    required this.amount,
    required this.fee,
    required this.description,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Image(
            image: AssetImage("images/starlogo.png"),
            height: 80,
            width: 80,
          ),
          const SizedBox(height: 8),
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF1D3A70),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('ID Transaction', transactionId),
          _buildDetailRow('Date', date),
          _buildDetailRow('Recipient', recipient),
          _buildDetailRow('Transaction Type', type),
          _buildDetailRow('Amount', '₦ $amount'),
          _buildDetailRow('Fee', '₦ $fee'),
          _buildDetailRow('Description', description),
          SizedBox(height: 15),
          _buildDetailRow('Total', '₦ $total', isBold: true),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7063E4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Share logic
                },
                child: const Text('Share', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF979797),
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFF56C2A),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
