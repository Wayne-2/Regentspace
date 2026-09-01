import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/notification_store.dart';

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
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        await NotificationStore.markAllRead(uid);
      } catch (_) {}
    });
  }

  Future<void> _deleteSelected() async {
    final uid = _uid;
    if (uid == null || _selected.isEmpty) return;
    final toDelete = _selected.toList();
    final count = toDelete.length;
    setState(() => _selected.clear());
    try {
      for (final id in toDelete) {
        await NotificationStore.deleteForUser(uid, id);
      }
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
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').get(const GetOptions(source: Source.server));
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 700));
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

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 244, 255),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 253, 244, 255),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(color: const Color(0xFFEAC5F7), borderRadius: BorderRadius.circular(10)),
          child: IconButton(icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 78, 6, 102), size: 20), onPressed: () => Navigator.pop(context)),
        ),
        title: Text(
          _selectionMode ? '${_selected.length} selected' : 'Notifications',
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 78, 6, 102)),
        ),
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              onPressed: _deleteSelected,
              tooltip: 'Delete selected',
            ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black54),
              onPressed: () => setState(() => _selected.clear()),
              tooltip: 'Cancel selection',
            ),
        ],
      ),
      body: uid == null
          ? _buildFallback()
          : StreamBuilder<List<AppNotification>>(
              stream: NotificationStore.watchForUser(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF740690)));
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Failed to load notifications:\n${snap.error}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'DMSans', color: Colors.red)),
                    ),
                  );
                }
                final notifications = snap.data ?? [];
                if (notifications.isEmpty) return _emptyState();
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF740690),
                  backgroundColor: Colors.white,
                  displacement: 40,
                  strokeWidth: 3,
                  elevation: 2,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: notifications.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isSelected = _selected.contains(n.id);
                      final isUnread = !n.isRead;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(n.id),
                          direction: DismissDirection.horizontal,
                          dismissThresholds: const {DismissDirection.startToEnd: 0.22, DismissDirection.endToStart: 0.22},
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(color: const Color(0xFF740690).withOpacity(0.10), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: const Color(0xFF740690), size: 20),
                                const SizedBox(width: 8),
                                Text(isSelected ? 'Deselect' : 'Slide to select', style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF740690), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(color: const Color(0xFF740690).withOpacity(0.10), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(isSelected ? 'Deselect' : 'Slide to select', style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF740690), fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: const Color(0xFF740690), size: 20),
                              ],
                            ),
                          ),
                          confirmDismiss: (dir) async {
                            _toggleSelect(n.id);
                            return false;
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (_selectionMode) _toggleSelect(n.id);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEAC5F7)
                                    : isUnread
                                        ? const Color(0xFFFFF0FC)
                                        : const Color.fromRGBO(255, 178, 255, 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? const Color(0xFF740690) : isUnread ? const Color(0xFF740690).withOpacity(0.14) : Colors.transparent, width: isSelected ? 1.5 : 1),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: const Color(0xFF740690).withOpacity(0.10),
                                      child: Icon(
                                        isSelected ? Icons.check_rounded : Icons.notifications_rounded,
                                        color: const Color(0xFF740690),
                                        size: 24,
                                      ),
                                    ),
                                    if (isUnread && !isSelected)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFFE53935), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5))),
                                      ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(n.title, style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700, color: Colors.black87))),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF740690), borderRadius: BorderRadius.circular(8)),
                                        child: const Text('SELECTED', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                                      )
                                    else if (isUnread)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF740690), borderRadius: BorderRadius.circular(8)),
                                        child: const Text('NEW', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.body.isEmpty ? (n.data['body']?.toString() ?? '') : n.body, style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black54, height: 1.3)),
                                      const SizedBox(height: 4),
                                      Text(_timeAgo(n.timestamp), style: const TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.black45)),
                                      const SizedBox(height: 2),
                                      Text('Slide to select', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Colors.black.withOpacity(0.35), fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFallback() {
    final real = NotificationStore.items;
    final notifications = real.isEmpty
        ? [
            {
              'title': 'Welcome to Regentspace 🎉',
              'message': 'Your account is ready. Pull down to refresh.',
              'time': 'now',
              'icon': Icons.waving_hand_rounded,
              'color': const Color(0xFF740690),
            },
          ]
        : real.map((n) => {
              'title': n.title,
              'message': n.body.isEmpty ? n.data.toString() : n.body,
              'time': _timeAgo(n.timestamp),
              'icon': Icons.notifications_rounded,
              'color': const Color(0xFF740690),
            }).toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF740690),
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: notifications.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          final item = notifications[index] as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 178, 255, 0.18),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: (item['color'] as Color).withOpacity(0.1),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                ),
                title: Text(item['title'] as String, style: const TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(item['message'] as String, style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black54, height: 1.3)),
                ),
                trailing: Text(item['time'] as String, style: const TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.black45)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF740690),
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
              const Text('No notifications yet', style: TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text('Pull down to refresh — welcome and virtual account updates will appear here.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Colors.black54)),
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
