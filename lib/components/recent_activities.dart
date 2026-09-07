import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../pages/dashboard/newusertab.dart';
import 'timeconverter.dart';

class RecentActivities extends StatelessWidget {
  final int limit;
  const RecentActivities({super.key, this.limit = 5});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseFirestore>(
      future: BuilderFirestore.instance,
      builder: (context, dbSnap) {
        if (dbSnap.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (dbSnap.hasError) {
          debugPrint('[RecentActivities] BuilderFirestore error: ${dbSnap.error}');
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
                  const SizedBox(height: 8),
                  Text('Failed to load activity', style: AppTextStyles.body(color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('${dbSnap.error}', style: AppTextStyles.caption(color: AppColors.textHint), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        final db = dbSnap.data;
        if (db == null) {
          debugPrint('[RecentActivities] BuilderFirestore returned null');
          return _buildEmpty();
        }

        // Query all apps to get their vtpass_transactions
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db
              .collection('apps')
              .doc('regentspace-builder')
              .collection('apps')
              .snapshots(),
          builder: (context, appsSnap) {
            if (appsSnap.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }
            if (appsSnap.hasError) {
              debugPrint('[RecentActivities] Apps stream error: ${appsSnap.error}');
              return _buildEmpty();
            }
            final apps = appsSnap.data?.docs ?? [];
            if (apps.isEmpty) {
              debugPrint('[RecentActivities] No apps found');
              return _buildEmpty();
            }

            // Collect all vtpass_transactions from all apps
            return FutureBuilder<List<_ActivityItem>>(
              future: _fetchAllTransactions(db, apps),
              builder: (context, txSnap) {
                if (txSnap.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                final items = txSnap.data ?? [];
                if (items.isEmpty) {
                  return _buildEmpty();
                }

                // Sort by timestamp descending and limit
                items.sort((a, b) {
                  final aTime = a.timestamp?.toDate() ?? DateTime(2000);
                  final bTime = b.timestamp?.toDate() ?? DateTime(2000);
                  return bTime.compareTo(aTime);
                });
                final displayItems = items.take(limit).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayItems.length,
                  itemBuilder: (_, index) {
                    final item = displayItems[index];
                    return _buildActivityTile(item);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<_ActivityItem>> _fetchAllTransactions(
    FirebaseFirestore db,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> apps,
  ) async {
    final items = <_ActivityItem>[];
    for (final app in apps) {
      try {
        debugPrint('[RecentActivities] Querying tx for app: ${app.id}');
        final txSnap = await app.reference
            .collection('vtpass_transactions')
            .limit(20)
            .get();
        debugPrint('[RecentActivities] Found ${txSnap.docs.length} tx for app ${app.id}');
        for (final tx in txSnap.docs) {
          final data = tx.data();
          items.add(_ActivityItem(
            username: data['username'] as String? ?? 'User',
            serviceUsed: data['service'] as String? ?? data['serviceType'] as String? ?? 'Service',
            amount: (data['amount'] as num?) ?? 0,
            timestamp: data['createdAt'] as Timestamp? ?? data['paidOn'] as Timestamp?,
            appId: app.id,
          ));
        }
      } catch (e) {
        debugPrint('[RecentActivities] Error fetching tx for app ${app.id}: $e');
      }
    }
    debugPrint('[RecentActivities] Total items found: ${items.length}');
    return items;
  }

  Widget _buildLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
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
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 12, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 4),
                  Container(width: 120, height: 10, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 36, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text('No recent activity yet', style: AppTextStyles.body(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(_ActivityItem item) {
    final amountStr = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(item.amount);
    final timeStr = item.timestamp != null ? formatTime(item.timestamp!.toDate().toIso8601String()) : '';

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
              child: Icon(getServiceIcon(item.serviceUsed), size: 18, color: AppColors.primary),
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
                    Expanded(child: Text(item.username, overflow: TextOverflow.ellipsis, style: AppTextStyles.body(color: AppColors.textPrimary))),
                    const SizedBox(width: 8),
                    Text(amountStr, style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.serviceUsed, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption(color: AppColors.textTertiary))),
                    const SizedBox(width: 8),
                    Text(timeStr, style: AppTextStyles.caption(color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String username;
  final String serviceUsed;
  final num amount;
  final Timestamp? timestamp;
  final String appId;

  _ActivityItem({
    required this.username,
    required this.serviceUsed,
    required this.amount,
    this.timestamp,
    required this.appId,
  });
}

IconData getServiceIcon(String service) {
  service = service.toLowerCase();
  if (service.contains("airtime")) return Icons.phone_android;
  if (service.contains("data")) return Icons.wifi;
  if (service.contains("tv") || service.contains("cable")) return Icons.tv;
  if (service.contains("electricity") || service.contains("electric")) return Icons.flash_on;
  if (service.contains("bet")) return Icons.sports_soccer;
  return Icons.receipt_rounded;
}
