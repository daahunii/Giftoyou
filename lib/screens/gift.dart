import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';

class Gift extends StatefulWidget {
  const Gift({super.key});

  @override
  State<Gift> createState() => _GiftState();
}

class _GiftState extends State<Gift> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final suggestions = await fetchGeminiSuggestions(query);
    setState(() {
      _suggestions = suggestions;
      _isLoadingSuggestions = false;
    });
  }

  Future<List<String>> fetchGeminiSuggestions(String keyword) async {
    const apiKey = 'AIzaSyBWtiy-F2NqgQFRCxBnkfQhYrV4rfJdG18';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final prompt = "'$keyword'에 대해 관련된 선물인데 검색창의 추천검색어처럼 입력창에 나온 글자를 포함하는 추천 키워드 5개를 제안해줘. 한 줄씩 출력해줘.";

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [{ "text": prompt }]
          }
        ]
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final text =
          data['candidates'][0]['content']['parts'][0]['text'] as String;
      return text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      print("Gemini error: \${res.statusCode}");
      return [];
    }
  }

  Widget _buildCategory(String title, String assetPath, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/categories',
          arguments: title,
        );
      },
      child: SizedBox(
        width: 160,
        height: 160,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? "User";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => _focusNode.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hi, $userName',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Color.fromARGB(255, 33, 96, 243), size: 28),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        user?.email ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      focusNode: _focusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: ' 추천 선물 검색',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            final keyword = _searchController.text.trim();
                            if (keyword.isNotEmpty) {
                              Navigator.pushNamed(context, '/searchResult', arguments: keyword);
                            }
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: const BoxDecoration(color: Colors.black12),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                "assets/categories/fruits.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '최대 60%\n파격 할인 중',
                                    style: TextStyle(
                                      color: Color(0xFFFED302),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    '*Applicable on selective products',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 110,
                                    height: 25,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        '🛒 구매하기',
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/categories');
                          },
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0D63D1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildCategory("Vegetables & Fruits", "assets/categories/vegetables.png", Color(0xFFEDF8E7), Color(0xFF47712F)),
                          _buildCategory("Fast foods", "assets/categories/fast_foods.png", Color(0xFFFFF3E5), Color(0xFF865214)),
                          _buildCategory("Dairy products", "assets/categories/dairy.png", Color(0xFFE4F6F6), Color(0xFF3C5D5D)),
                          _buildCategory("Home care", "assets/categories/home_care.png", Color(0xFFFEF7E5), Color(0xFF6F5614)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (_focusNode.hasFocus && _suggestions.isNotEmpty)
                Positioned(
                  top: 180,
                  left: width * 0.05,
                  right: width * 0.05,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingSuggestions
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: _suggestions
                                  .map((s) => ListTile(
                                        title: Text(s),
                                        onTap: () {
                                          _searchController.text = s;
                                          _focusNode.unfocus();
                                        },
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
