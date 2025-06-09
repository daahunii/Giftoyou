import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> friendNotifications = [];

  @override
  void initState() {
    super.initState();
    fetchFriendNotifications();
  }

  Future<void> fetchFriendNotifications() async {
    if (currentUser == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('friends')
          .orderBy('addedAt', descending: true)
          .get();

      final List<Map<String, dynamic>> notis = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Unknown',
          'profileImage': data['photoURL'] ?? 'assets/gift_close.png',
          'time': data['addedAt']?.toDate(),
        };
      }).toList();

      setState(() {
        friendNotifications = notis;
      });
    } catch (e) {
      print("❌ 알림 로드 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                '알림',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFilterChip('알림', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('주문현황', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('재입고', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('즐겨찾기', false),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...friendNotifications.map((noti) {
                      final date = noti['time'] as DateTime?;
                      final timeText = date != null
                          ? '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                          : '';

                      return _buildNotificationItem(
                        avatar: noti['profileImage'],
                        name: noti['name'],
                        time: timeText,
                        message: '${noti['name']} 친구가 추가되었습니다!',
                      );
                    }).toList(),

                    _buildNotificationItem(
                      avatar: 'assets/gift_close.png',
                      name: 'Giftoyou',
                      time: '오늘',
                      message: '오늘의 선물 추천이 올라왔어요!',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0D63D1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String avatar,
    required String name,
    required String time,
    required String message,
    String? subText,
    Widget? trailing,
  }) {
    final bool isNetwork = avatar.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: isNetwork
                    ? NetworkImage(avatar)
                    : AssetImage(avatar) as ImageProvider,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: time),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
                if (subText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subText,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );
  }
}