import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/notification_store.dart';
import '../theme/app_theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  final Set<String> _selected = {};
  bool get _selectionMode => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = _uid;
      if (uid == null) return;
      await NotificationStore.initLocal();
      NotificationStore.startFirestoreListener(uid);
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        await NotificationStore.markAllReadLocal(uid);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    NotificationStore.stopFirestoreListener();
    super.dispose();
  }

  Future<void> _deleteSelected() async {
    final uid = _uid;
    if (uid == null || _selected.isEmpty) return;
    final toDelete = _selected.toList();
    final count = toDelete.length;
    setState(() => _selected.clear());
    try {
      await NotificationStore.deleteMultiple(uid, toDelete);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count notification${count > 1 ? 's' : ''} deleted'), backgroundColor: const Color(0xFF740690)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red.shade700));
    }
  }

  Future<void> _onRefresh() async {
    final uid = _uid;
    if (uid != null) {
      await NotificationStore.syncFromFirestore(uid);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() {});
  }

  void _toggleSelect(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  IconData _notifIcon(AppNotification n) {
    final src = (n.data['source'] ?? '').toString();
    if (src.contains('monnify') || src.contains('wallet') || src.contains('fund')) return Icons.account_balance_wallet_rounded;
    if (src.contains('build') || src.contains('canva')) return Icons.phone_android_rounded;
    if (src.contains('auth') || src.contains('login') || src.contains('welcome')) return Icons.person_rounded;
    if (src.contains('rate') || src.contains('interest')) return Icons.trending_up_rounded;
    return Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectionMode ? '${_selected.length} selected' : 'Notifications',
          style: AppTextStyles.headline(color: AppColors.textPrimary),
        ),
        actions: [
          if (_selectionMode) ...[
            TextButton(
              onPressed: _deleteSelected,
              child: const Text('Delete', style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black54, size: 20),
              onPressed: () => setState(() => _selected.clear()),
            ),
          ],
        ],
      ),
      body: uid == null
          ? _buildFallback()
          : StreamBuilder<List<AppNotification>>(
              stream: NotificationStore.localStream,
              initialData: NotificationStore.items,
              builder: (context, snap) {
                final notifications = snap.data ?? [];
                if (notifications.isEmpty) return _emptyState();
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  displacement: 40,
                  strokeWidth: 3,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: notifications.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isSelected = _selected.contains(n.id);
                      final isUnread = !n.isRead;
                      return _buildTile(n, isSelected, isUnread);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTile(AppNotification n, bool isSelected, bool isUnread) {
    final body = n.body.isEmpty ? (n.data['body']?.toString() ?? '') : n.body;
    final timeStr = _timeAgo(n.timestamp);

    return GestureDetector(
      onTap: () {
        if (_selectionMode) _toggleSelect(n.id);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _toggleSelect(n.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEAC5F7)
              : isUnread
                  ? const Color(0xFFFDF4FF)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isUnread
                    ? const Color(0xFFEAC5F7)
                    : const Color(0xFFE8E8EA),
            width: isSelected ? 1.5 : 1,
          ),
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
                child: isSelected
                    ? Icon(Icons.check_rounded, size: 18, color: AppColors.primary)
                    : Icon(_notifIcon(n), size: 18, color: AppColors.primary),
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
                      Expanded(
                        child: Text(
                          n.title,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Text('SELECTED', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                        )
                      else if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Text('NEW', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          body,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTextStyles.caption(color: AppColors.textTertiary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(timeStr, style: AppTextStyles.caption(color: AppColors.textHint)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    final real = NotificationStore.items;
    final notifications = real.isEmpty
        ? [
            {
              'title': 'Welcome to Regentspace',
              'message': 'Your account is ready. Pull down to refresh.',
              'time': 'now',
              'icon': Icons.waving_hand_rounded,
            },
          ]
        : real.map((n) => {
              'title': n.title,
              'message': n.body.isEmpty ? n.data.toString() : n.body,
              'time': _timeAgo(n.timestamp),
              'icon': Icons.notifications_rounded,
            }).toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: notifications.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          final item = notifications[index] as Map<String, dynamic>;
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
                    child: Icon(item['icon'] as IconData, size: 18, color: AppColors.primary),
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
                          Expanded(child: Text(item['title'] as String, overflow: TextOverflow.ellipsis, style: AppTextStyles.body(color: AppColors.textPrimary))),
                          const SizedBox(width: 8),
                          Text(item['time'] as String, style: AppTextStyles.caption(color: AppColors.textHint)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item['message'] as String, overflow: TextOverflow.ellipsis, maxLines: 2, style: AppTextStyles.caption(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none_rounded, size: 36, color: Color(0xFF740690)),
              ),
              const SizedBox(height: 14),
              Text('No notifications yet', style: AppTextStyles.title(color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('Pull down to refresh — welcome and virtual account updates will appear here.', textAlign: TextAlign.center, style: AppTextStyles.caption(color: AppColors.textTertiary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
