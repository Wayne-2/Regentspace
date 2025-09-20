import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionHistoryPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF9FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  //borderSide: BorderSide(color: Color(0xFFF9FAFC))
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Transaction List or Empty Message
          Expanded(
            child: transactions.isEmpty
                ? const Center(
              child: Text(
                'No transaction for now.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: transactions.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isCredit = tx['isCredit'] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: tx['icon'] ?? const Icon(Icons.swap_horiz),
                      ),
                      const SizedBox(width: 12),

                      // Title + Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tx['time'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      Text(
                        '${isCredit ? '+' : '-'} ₦ ${tx['amount']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Color(0xFF8FC93A) : Color(0xFFFF2E00),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}
