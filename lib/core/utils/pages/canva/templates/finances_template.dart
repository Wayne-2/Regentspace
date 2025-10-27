import 'package:flutter/material.dart';
import 'package:newregentspace/core/utils/pages/canva/widgets/usageinfo.dart';

class FinancesTemplate extends StatelessWidget {
  const FinancesTemplate({
    super.key,
    required this.primaryapptheme,
  });

  final Color primaryapptheme;
  static const double _aspectRatio = 19.5 / 9; // iPhone 14 ratio

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 232, 221),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header card ---
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: primaryapptheme,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Solomon',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Prepaid - 5235829243',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Manage account',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            /// --- Usage Info ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Usageinfo(
                    amount: '20,000.00',
                    rating: 'Kes',
                    servicetype: 'Airtime',
                    fontsize: 10),
                Usageinfo(
                    amount: '4000',
                    rating: 'Mms',
                    servicetype: 'Voice Bundle',
                    fontsize: 10),
                Usageinfo(
                    amount: '2,903.00',
                    rating: 'Mb',
                    servicetype: 'Data Bundle',
                    fontsize: 10),
              ],
            ),

            const SizedBox(height: 6),

            /// --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton("History"),
                _actionButton("Schedule payments"),
              ],
            ),

            const SizedBox(height: 8),

            /// --- Section Title ---
            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            /// --- Transactions list ---
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black12, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Leading icon
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(Icons.wallet_outlined, size: 10),
                          ),
                          const SizedBox(width: 8),

                          // Title and timestamp
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Loan payment',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '12:00pm',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount
                          const Text(
                            '+3,000',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- Button builder helper ---
  Widget _actionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black, width: 1),
        color: primaryapptheme,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
      ),
    );
  }
}
