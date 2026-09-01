import 'package:flutter/material.dart';
import 'timeconverter.dart';
import 'userpfp.dart';

// Static UI only — no Supabase / stream.
class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  static const mockActivities = [
    {'username': 'Akano James', 'service_used': 'NECO Token Purchase', 'amount': '3000', 'created_at': '2025-04-20T10:30:00Z'},
    {'username': 'Jessica Okie', 'service_used': 'Airtime Subscription', 'amount': '1500', 'created_at': '2025-04-20T09:15:00Z'},
    {'username': 'Sunday John', 'service_used': 'Cable TV Subscription', 'amount': '5000', 'created_at': '2025-04-19T18:00:00Z'},
    {'username': 'Ifeanyi Opara', 'service_used': 'Electricity Bill', 'amount': '7500', 'created_at': '2025-04-19T14:20:00Z'},
  ];

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
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              UserAvatar(name: username, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(username, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 13.5))),
                        const SizedBox(width: 8),
                        Text("₦ $amount", style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 12.5, color: const Color(0xFF1F1F1F))),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(serviceUsed, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w400, fontSize: 11.5, color: Colors.black.withOpacity(0.55)))),
                        const SizedBox(width: 8),
                        Text(createdAt, style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w400, fontSize: 10.5, color: Colors.black.withOpacity(0.5))),
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
