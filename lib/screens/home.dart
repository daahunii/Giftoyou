import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addfriends.dart';
import 'gift.dart';
import 'profile.dart';
import 'notification.dart';
import 'calendar.dart';
import 'friendsList.dart';
import 'dailyGift.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    const CalendarPage(),
    const Gift(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D63D1),
        unselectedItemColor: const Color(0xFFA0A3B2),
        backgroundColor: Colors.white,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        elevation: 0,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined, size: 24), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined, size: 26), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined, size: 26), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), label: ''),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> _recommendedItems = [];
  bool _loadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedItems();
  }

  Future<List<String>> fetchGeminiRecommendations() async {
    const apiKey = 'AIzaSyBWtiy-F2NqgQFRCxBnkfQhYrV4rfJdG18';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final prompt = "지금 시점 기준 네이버 쇼핑에서 인기 있는 선물 아이템 5개 키워드를 추천해줘. 한 줄에 하나씩 출력해줘.";

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [{"text": prompt}]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      print("Gemini error: ${response.statusCode}");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchNaverShopping(String keyword) async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8081/search?query=$keyword"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      print("Naver API error: ${response.statusCode}");
      return [];
    }
  }

  Future<void> _fetchRecommendedItems() async {
    try {
      final keywords = await fetchGeminiRecommendations();
      final List<Map<String, dynamic>> items = [];

      for (final keyword in keywords) {
        final results = await searchNaverShopping(keyword);
        if (results.isNotEmpty) {
          items.add(results.first);
        }
      }

      setState(() {
        _recommendedItems = items;
        _loadingRecommendations = false;
      });
    } catch (e) {
      print('❌ 추천 상품 불러오기 오류: $e');
      setState(() => _loadingRecommendations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? "User";

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  "Welcome, $userName",
                  style: const TextStyle(
                    color: Color(0xFF3F414E),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "소중한 사람들에게 행복을 전하세요!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA0A3B2),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildFeatureCard(
                      context: context,
                      titleKo: "친구 추가",
                      titleEn: "Add your Friends!",
                      color: const Color(0xFF3485FF),
                      imagePath: "assets/heartalarm.png",
                      rotate: 0.65,
                      textColor: Colors.white,
                      buttonColor: const Color(0xFFEBEAEC),
                      buttonTextColor: const Color(0xFF3F414E),
                      navigateTo: const AddFriends(),
                    ),
                    const SizedBox(width: 12),
                    _buildFeatureCard(
                      context: context,
                      titleKo: "선물하기",
                      titleEn: "Gift your Friends!",
                      color: const Color(0xFFFF8A8C),
                      imagePath: "assets/gift_close.png",
                      rotate: 0.0,
                      textColor: const Color(0xFF3F414E),
                      buttonColor: const Color(0xFF3F414E),
                      buttonTextColor: Colors.white,
                      navigateTo: const FriendsListPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDailyGiftCard(context, width),
                const SizedBox(height: 24),
                const Text(
                  "인기 상품 추천 리스트",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF3F414E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecommendationList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String titleKo,
    required String titleEn,
    required Color color,
    required String imagePath,
    required Color textColor,
    required Color buttonColor,
    required Color buttonTextColor,
    double rotate = 0.0,
    required Widget navigateTo,
  }) {
    return Expanded(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 9,
              right: 9,
              child: Transform.rotate(
                angle: rotate,
                child: Image.asset(imagePath, width: 100, height: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(titleKo, style: TextStyle(color: textColor, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(titleEn, style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 12)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => navigateTo),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text("START", style: TextStyle(color: buttonTextColor, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGiftCard(BuildContext context, double width) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DailyGiftPage()),
        );
      },
      child: Container(
        width: width,
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF333242),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Daily Gift Recommend", style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 6),
                Text("오늘의 특별한 선물을 추천드려요!", style: TextStyle(color: Color(0xFFEBEAEC), fontSize: 11)),
              ],
            ),
            const Spacer(),
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.chevron_right, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationList() {
    if (_loadingRecommendations) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _recommendedItems.map((item) {
          final image = item['image'] ?? '';
          final title = (item['title'] ?? '').replaceAll(RegExp(r'<[^>]*>'), '');

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(image, width: 150, height: 120, fit: BoxFit.cover),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3F414E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(item['mallName'] ?? '', style: const TextStyle(color: Color(0xFFA1A4B2), fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}