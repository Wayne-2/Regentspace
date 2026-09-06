import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'timeconverter.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  static const mockActivities = [
    {'username': 'Akano James', 'service_used': 'NECO Token Purchase', 'amount': '3000', 'created_at': '2025-04-20T10:30:00Z'},
    {'username': 'Jessica Okie', 'service_used': 'Airtime Subscription', 'amount': '1500', 'created_at': '2025-04-20T09:15:00Z'},
    {'username': 'Sunday John', 'service_used': 'Cable TV Subscription', 'amount': '5000', 'created_at': '2025-04-19T18:00:00Z'},
    {'username': 'Ifeanyi Opara', 'service_used': 'Electricity Bill', 'amount': '7500', 'created_at': '2025-04-19T14:20:00Z'},
  ];

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockActivities.length,
      itemBuilder: (_, index) {
        final user = mockActivities[index];
        final username = user['username']!;
        final serviceUsed = user['service_used']!;
        final amount = user['amount']!;
        final createdAt = formatTime(user['created_at']!);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8EA)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
                ),
                child: Center(
                  child: Text(
                    _getInitials(username),
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(username, overflow: TextOverflow.ellipsis, style: AppTextStyles.body(color: AppColors.textPrimary))),
                        const SizedBox(width: 8),
                        Text("₦$amount", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(serviceUsed, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption(color: AppColors.textTertiary))),
                        const SizedBox(width: 8),
                        Text(createdAt, style: AppTextStyles.caption(color: AppColors.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

IconData getServiceIcon(String service) {
  service = service.toLowerCase();
  if (service.contains("airtime")) return Icons.phone_android;
  if (service.contains("data")) return Icons.wifi;
  if (service.contains("tv")) return Icons.tv;
  if (service.contains("electricity")) return Icons.flash_on;
  if (service.contains("bet")) return Icons.sports_soccer;
  return Icons.history;
}
