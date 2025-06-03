import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:giftoyou/screens/home.dart';

class DailyGiftPage extends StatefulWidget {
  const DailyGiftPage({super.key});

  @override
  State<DailyGiftPage> createState() => _DailyGiftPageState();
}

class _DailyGiftPageState extends State<DailyGiftPage> {
  bool _isLoading = true;
  Map<String, dynamic> _naverResults = {};
  final Map<int, int> cart = {};

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
    _fetchDailyGift();
  }

  Future<void> _fetchDailyGift() async {
    try {
      const apiKey = 'AIzaSyBWtiy-F2NqgQFRCxBnkfQhYrV4rfJdG18';
      const geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

      final prompt = '''
      오늘 하루를 위한 특별한 선물 10가지를 추천해줘. 항목당 한 줄 키워드만 출력해줘.
      예시:
      1. 따뜻한 담요
      2. 향기로운 차 세트
      3. ...
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
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 64,
            "topP": 0.95,
            "maxOutputTokens": 1024,
            "responseMimeType": "text/plain"
          }
        }),
      );

      if (geminiRes.statusCode != 200) throw Exception('Gemini failed');

      final data = jsonDecode(geminiRes.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

      final keywords = text
          .split('\n')
          .map((e) => e.replaceAll(RegExp(r'^\d+\. '), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final naverRes = await http.post(
        Uri.parse('http://127.0.0.1:8081/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keywords': keywords}),
      );

      if (naverRes.statusCode != 200) throw Exception('Naver API failed');

      setState(() {
        _naverResults = jsonDecode(naverRes.body);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          '오늘의 추천 선물',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
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
                    left: 16,
                    right: 16,
                    bottom: 32,
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
                            'VIEW CART 🛍️',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}