import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
                    _buildNotificationItem(
                      avatar: 'assets/avatar1.png',
                      name: 'starryskies23',
                      time: '1d',
                      message: 'Started following you',
                      trailing: _buildFollowButton(),
                    ),
                    _buildNotificationItem(
                      avatar: 'assets/avatar2.png',
                      name: 'nebulanomad',
                      time: '1d',
                      message: 'nebula님께 선물 발송완료!',
                      trailing: _buildThumbnail(),
                    ),
                    _buildNotificationItem(
                      avatar: 'assets/gift_icon.png',
                      name: 'Giftoyou',
                      time: '2d',
                      message: '오늘의 선물 추천이 올라왔어요!',
                    ),
                    _buildNotificationItem(
                      avatar: 'assets/avatar3.png',
                      name: 'lunavoyager',
                      time: '3d',
                      message: 'Saved your post',
                      trailing: _buildThumbnail(),
                    ),
                    _buildNotificationItem(
                      avatar: 'assets/avatar4.png',
                      name: 'shadowlynx',
                      time: '4d',
                      message: 'Commented on your post',
                      subText: 
                          "i’m going in september. what about you?",
                      trailing: _buildThumbnail(),
                    ),
                    _buildNotificationItem(
                      avatar: 'assets/avatar3.png',
                      name: 'lunavoyager',
                      time: '5d',
                      message: 'Liked your comment',
                      subText: 'This is so adorable!!!',
                      trailing: _buildThumbnail(),
                    ),
                  ],
                ),
              )
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(avatar),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
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

  Widget _buildFollowButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D63D1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '친구추가',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/thumb_sample.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
