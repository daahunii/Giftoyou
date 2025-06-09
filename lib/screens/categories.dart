import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giftoyou/screens/home.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _isLoading = true;
  Map<String, dynamic> _naverResults = {};
  final Map<int, int> cart = {};

  String selectedCategory = 'All Categories';

  final List<String> categories = [
    'All Categories',
    'Vegetables & Fruits',
    'Fast foods',
    'Dairy products',
    'Home care',
  ];

  String formatCurrency(String? price) {
    final formatter = NumberFormat('#,###');
    try {
      return formatter.format(int.parse(price ?? '0'));
    } catch (_) {
      return '0';
    }
  }

  String formatCurrencyInt(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  int get totalItemCount => cart.values.fold(0, (a, b) => a + b);

  int get totalPrice {
    int sum = 0;
    items.asMap().forEach((index, item) {
      if (cart.containsKey(index)) {
        try {
          sum += int.parse(item['lprice'] ?? '0') * cart[index]!;
        } catch (_) {}
      }
    });
    return sum;
  }

  List<Map<String, dynamic>> get items {
    return _naverResults.values.expand((e) => List<Map<String, dynamic>>.from(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && categories.contains(args)) {
        setState(() {
          selectedCategory = args;
        });
      }
      _fetchCategoryGifts();
    });
  }

  Future<void> _fetchCategoryGifts() async {
    try {
      const apiKey = 'AIzaSyBWtiy-F2NqgQFRCxBnkfQhYrV4rfJdG18';
      const geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

      final prompt = selectedCategory == 'All Categories'
          ? '''
        선물로 인기 있는 카테고리별 품목 20가지를 추천해줘. 한 줄 키워드 형태로 출력해줘.
        예시:
        1. 휴대용 가습기
        2. 무선 이어폰
        ...
        '''
          : '''
        "$selectedCategory" 카테고리에서 선물로 인기 있는 품목 15가지를 추천해줘. 한 줄 키워드 형태로 출력해줘. 그리고 만약에 패스트푸드가 카테고리라면, 1. 햄버거, 2. 피자 와 같이 포괄적으로 한줄씩 출력해줘.
        예시:
        1. 휴대용 가습기
        2. 무선 이어폰
        ...
        ''';

      final geminiRes = await http.post(
        Uri.parse(geminiUrl),
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

      if (geminiRes.statusCode != 200) throw Exception('Gemini failed');

      final data = jsonDecode(geminiRes.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

      final keywords = text
          .split('\n')
          .map((e) => e.replaceAll(RegExp(r'^\d+[.\)]?\s*'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final naverRes = await http.post(
        Uri.parse('http://127.0.0.1:8081/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keywords': keywords}),
      );

      if (naverRes.statusCode != 200) throw Exception('Naver API failed');

      if (!mounted) return;
      setState(() {
        _naverResults = jsonDecode(naverRes.body);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 오류 발생: $e');
    }
  }

  Future<void> saveCartToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final docRef = FirebaseFirestore.instance.collection('carts').doc(uid);
    final doc = await docRef.get();

    List<Map<String, dynamic>> existingItems = [];
    if (doc.exists) {
      final data = doc.data();
      existingItems = List<Map<String, dynamic>>.from(data?['items'] ?? []);
    }

    final newItems = cart.entries.map((entry) {
      final item = items[entry.key];
      return {
        'title': item['title'].replaceAll(RegExp(r'<[^>]*>'), ''),
        'image': item['image'],
        'lprice': item['lprice'],
        'quantity': entry.value,
        'mallName': item['mallName'] ?? '알 수 없음',
      };
    }).toList();

    for (var newItem in newItems) {
      final existingIndex = existingItems.indexWhere((item) =>
          item['title'] == newItem['title'] &&
          item['mallName'] == newItem['mallName']);

      if (existingIndex != -1) {
        existingItems[existingIndex]['quantity'] += newItem['quantity'];
      } else {
        existingItems.add(newItem);
      }
    }

    await docRef.set({'items': existingItems});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategory,
            alignment: Alignment.center,
            isDense: true,
            style: const TextStyle(
              color: Color(0xFF0D63D1),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            icon: const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCategory = newValue;
                  _isLoading = true;
                  _fetchCategoryGifts();
                });
              }
            },
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.grey),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final image = item['image'] ?? '';
                      final title = (item['title'] ?? '').replaceAll(RegExp(r'<[^>]*>'), '');
                      final mallName = item['mallName'] ?? '알 수 없음';
                      final lprice = item['lprice'] ?? '0';
                      final quantity = cart[index] ?? 0;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mallName,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${formatCurrency(lprice)}원",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 24, 67, 175)),
                            ),
                            const SizedBox(height: 9),
                            Align(
                              alignment: Alignment.center,
                              child: quantity == 0
                                  ? ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          cart[index] = 1;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDCF0FA),
                                        foregroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                      ),
                                      child: const Text('선물하기', style: TextStyle(fontSize: 15)),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          iconSize: 20,
                                          onPressed: () {
                                            setState(() {
                                              if (cart[index]! > 1) {
                                                cart[index] = cart[index]! - 1;
                                              } else {
                                                cart.remove(index);
                                              }
                                            });
                                          },
                                        ),
                                        Text('${cart[index]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          iconSize: 20,
                                          onPressed: () {
                                            setState(() {
                                              cart[index] = cart[index]! + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (cart.isNotEmpty)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 50,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await saveCartToFirebase();
                        setState(() => cart.clear());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('장바구니에 상품들이 추가되었어요!')),
                        );
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D63D1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '총 ${totalItemCount}개 | ${formatCurrencyInt(totalPrice)}원',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text(
                              '장바구니 담기 🛍️',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
