import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MonitorInterestPage extends StatefulWidget {
  const MonitorInterestPage({super.key});

  @override
  State<MonitorInterestPage> createState() => _MonitorInterestPageState();
}

class _MonitorInterestPageState extends State<MonitorInterestPage> {
  String _selectedPeriod = 'This Month';

  final List<String> _periods = ['Today', 'This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Monitor Interest", style: AppTextStyles.headline(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Period selector ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                        ),
                        child: Center(
                          child: Text(
                            period,
                            style: AppTextStyles.caption(
                              color: isSelected ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ── Interest summary card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Interest Earnings", style: AppTextStyles.titleSmall(color: AppColors.primaryDark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryItem("Total Earned", "₦12,500.00")),
                      Container(width: 1, height: 40, color: AppColors.primaryLight),
                      Expanded(child: _buildSummaryItem("Interest Rate", "25%")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryItem("Transactions", "48")),
                      Container(width: 1, height: 40, color: AppColors.primaryLight),
                      Expanded(child: _buildSummaryItem("Avg. per Transaction", "₦260.42")),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Interest breakdown ──
            Text("Interest Breakdown", style: AppTextStyles.title(color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            _buildBreakdownItem("Airtime Purchases", "₦5,200.00", "20 transactions", Icons.phone_android, const Color(0xFF4CAF50)),
            _buildBreakdownItem("Data Purchases", "₦4,800.00", "15 transactions", Icons.wifi, const Color(0xFF2196F3)),
            _buildBreakdownItem("Cable TV Payments", "₦1,500.00", "8 transactions", Icons.tv, const Color(0xFFFF9800)),
            _buildBreakdownItem("Electricity Bills", "₦1,000.00", "5 transactions", Icons.flash_on, const Color(0xFF9C27B0)),

            const SizedBox(height: 24),

            // ── Recent interest entries ──
            Text("Recent Interest Entries", style: AppTextStyles.title(color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            _buildInterestEntry("Airtime - MTN", "₦120.00", "2 hours ago"),
            _buildInterestEntry("Data - GLO", "₦85.00", "5 hours ago"),
            _buildInterestEntry("Cable TV - DSTV", "₦250.00", "Yesterday"),
            _buildInterestEntry("Electricity - IKEDC", "₦500.00", "Yesterday"),
            _buildInterestEntry("Airtime - Airtel", "₦95.00", "2 days ago"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildBreakdownItem(String title, String amount, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(amount, style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildInterestEntry(String service, String amount, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8EA)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service, style: AppTextStyles.body(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.caption(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text("+$amount", style: AppTextStyles.titleSmall(color: const Color(0xFF4CAF50))),
        ],
      ),
    );
  }
}
