import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../components/userpfp.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  // Static mock users — no API
  static const mockUsers = [
    {'username': 'Akano James'},
    {'username': 'Jessica Okie'},
    {'username': 'Sunday John'},
    {'username': 'Ifeanyi Opara'},
    {'username': 'Ada Loveth'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mockUsers.length,
        itemBuilder: (_, index) {
          final username = mockUsers[index]['username']!;
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                UserAvatar(name: username, size: 44),
                const SizedBox(height: 6),
                SizedBox(
                  width: 64,
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF1F1F1F)),
                  ),
                ),
              ],
            ),
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
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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
