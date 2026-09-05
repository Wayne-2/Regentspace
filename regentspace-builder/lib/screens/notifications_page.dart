import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/notification_store.dart';
import '../service/app_tenant.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _syncNotifications();
  }

  Future<void> _syncNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await NotificationStore.syncFromFirestore(uid);
      NotificationStore.startFirestoreListener(uid);
    }
  }

  @override
  void dispose() {
    NotificationStore.stopFirestoreListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Notifications',
          style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF333333),
        actions: [
          if (uid.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, size: 20),
              onPressed: () async {
                await NotificationStore.markAllReadLocal(uid);
              },
            ),
          if (uid.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all?'),
                    content: const Text('This will remove all notifications.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) await NotificationStore.clearAll(uid);
              },
            ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationStore.localStream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? NotificationStore.items;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 48, color: Color(0xFFCCCCCC)),
                  const SizedBox(height: 12),
                  Text('No notifications yet',
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0xFF999999))),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = items[i];
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await NotificationStore.deleteNotification(uid, n.id);
                },
                child: GestureDetector(
                  onTap: () async {
                    if (!n.isRead) await NotificationStore.markAsReadLocal(uid, n.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.isRead ? Colors.white : const Color(0xFFF0F0FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: n.isRead ? const Color(0xFFF0F0F0) : const Color(0xFF6C0090).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                            size: 16,
                            color: n.isRead ? const Color(0xFF999999) : const Color(0xFF6C0090),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 13,
                                  fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                  color: const Color(0xFF333333))),
                              const SizedBox(height: 4),
                              Text(n.body,
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFF888888))),
                              const SizedBox(height: 6),
                              Text(_formatTime(n.timestamp),
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: Color(0xFFBBBBBB))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
