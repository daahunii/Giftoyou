import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchResultPage extends StatefulWidget {
  final String keyword;
  const SearchResultPage({super.key, required this.keyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _results = [];
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
    _results.asMap().forEach((index, item) {
      if (cart.containsKey(index)) {
        try {
          sum += int.parse(item['lprice'] ?? '0') * cart[index]!;
        } catch (_) {}
      }
    });
    return sum;
  }

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<void> _fetchSearchResults() async {
    try {
      final naverRes = await http.post(
        Uri.parse('http://127.0.0.1:8081/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keywords': [widget.keyword]}),
      );

      if (naverRes.statusCode != 200) throw Exception('Naver API failed');

      final data = jsonDecode(naverRes.body) as Map<String, dynamic>;

      final List<Map<String, dynamic>> parsed = [];

      for (var value in data.values) {
        if (value is List) {
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              parsed.add(item);
            } else if (item is Map) {
              parsed.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
      setState(() {
        _results = parsed;
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
    final cartData = cart.entries.map((entry) {
      final item = _results[entry.key];
      return {
        'image': item['image'],
        'title': item['title'].replaceAll(RegExp(r'<[^>]*>'), ''),
        'mallName': item['mallName'] ?? '알 수 없음',
        'lprice': item['lprice'],
        'quantity': entry.value,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('carts').doc(uid).set({
      'items': cartData,
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '"${widget.keyword}" 검색 결과',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    itemCount: _results.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final item = _results[index];
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
                    left: 16,
                    right: 16,
                    bottom: 32,
                    child: GestureDetector(
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
