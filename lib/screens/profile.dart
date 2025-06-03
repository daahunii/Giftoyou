import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    final userName = displayName != null && displayName.isNotEmpty
        ? displayName
        : (user?.email?.split('@').first ?? 'User');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '마이페이지',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black87),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 90,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/gift_close.png'),
              ),
              const SizedBox(height: 20),
              Text(
                userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Edit profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 28),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About Me:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A4496),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: '등록된 친구 목록',
                    description: '내가 등록한 친구들의 리스트를 확인해보세요.',
                    color: const Color(0xFFF3F3FF),
                    iconColor: Colors.deepPurple,
                    bookmarkColor: Colors.deepPurple,
                    onTap: () {
                      Navigator.pushNamed(context, '/friendsList');
                    },
                  ),
                  _buildInfoCard(
                    icon: Icons.calendar_month_outlined,
                    title: '예정된 기념일 목록',
                    description: '다가오는 생일, 기념일을 미리 확인하세요.',
                    color: const Color(0xFFE6F7F6),
                    iconColor: Colors.teal,
                    bookmarkColor: Colors.teal,
                    onTap: () {
                      Navigator.pushNamed(context, '/calendar');
                    },
                  ),
                  _buildInfoCard(
                    icon: Icons.check_box_outlined,
                    title: '주고받은 선물추억',
                    description: '지금까지 주고받은 선물의 기록을 확인해보세요.',
                    color: const Color(0xFFFFF2F2),
                    iconColor: Colors.deepOrange,
                    bookmarkColor: Colors.deepOrange,
                  ),
                  _buildInfoCard(
                    icon: Icons.favorite_border,
                    title: '찜한 선물 목록',
                    description: '나중에 사고 싶은 선물들을 모아봤어요.',
                    color: const Color(0xFFFFF2FA),
                    iconColor: Colors.pink,
                    bookmarkColor: Colors.pink,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
    required Color bookmarkColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.bookmark, color: bookmarkColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}