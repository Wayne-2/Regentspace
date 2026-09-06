import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';

/// Secondary Firebase app for reading from regentspace-builder project.
/// The regentspace app itself runs on `regentsspace` project,
/// but generated apps live under `regentspace-builder`.
class BuilderFirestore {
  static FirebaseApp? _app;
  static FirebaseFirestore? _db;

  static Future<FirebaseFirestore> get instance async {
    if (_db != null) return _db!;

    _app = await Firebase.initializeApp(
      name: 'regentspace-builder',
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDKvRGEE-9HcPtrJqrAlR0ZD4020BKa9NQ',
        appId: '1:540697819834:android:fea3c4853d6afb31c82083',
        messagingSenderId: '540697819834',
        projectId: 'regentspace-builder',
        storageBucket: 'regentspace-builder.firebasestorage.app',
      ),
    );
    _db = FirebaseFirestore.instanceFor(app: _app!);
    return _db!;
  }
}

class UserList extends StatelessWidget {
  final String? appId;
  const UserList({super.key, this.appId});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (appId == null || appId!.isEmpty) {
      return const SizedBox(
        height: 76,
        child: Center(
          child: Text('No new user yet', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFFAAAAAA))),
        ),
      );
    }

    return SizedBox(
      height: 76,
      child: FutureBuilder<FirebaseFirestore>(
        future: BuilderFirestore.instance,
        builder: (context, dbSnap) {
          if (dbSnap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, __) => shimmerUserItem(),
            );
          }
          final db = dbSnap.data;
          if (db == null) {
            return const SizedBox(
              height: 76,
              child: Center(child: Text('Config error', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFFC62828)))),
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: db
                .collection('apps')
                .doc('regentspace-builder')
                .collection('apps')
                .doc(appId)
                .collection('users')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (_, __) => shimmerUserItem(),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const SizedBox(
                  height: 76,
                  child: Center(
                    child: Text('No new user yet', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFFAAAAAA))),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (_, index) {
                  final data = docs[index].data();
                  final username = (data['username'] as String?) ?? (data['email'] as String?) ?? 'User';
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 64,
                          child: Text(
                            username,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Widget shimmerUserItem() {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    ),
  );
}
