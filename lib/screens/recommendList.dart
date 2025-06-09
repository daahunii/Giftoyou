import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giftoyou/screens/home.dart';

class RecommendListPage extends StatefulWidget {
  final String friendName;
  final String avatarPath;
  final Map<String, dynamic> naverResults;

  const RecommendListPage({
    super.key,
    required this.friendName,
    required this.avatarPath,
    required this.naverResults,
  });

  @override
  State<RecommendListPage> createState() => _RecommendListPageState();
}

class _RecommendListPageState extends State<RecommendListPage> {
  final Map<int, int> cart = {};

  String formatCurrency(String price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(int.parse(price));
  }

  String formatCurrencyInt(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  int get totalItemCount => cart.values.fold(0, (a, b) => a + b);

  int get totalPrice {
    int sum = 0;
    widget.naverResults.forEach((_, list) {
      for (var i = 0; i < list.length; i++) {
        final index = items.indexOf(list[i]);
        if (cart.containsKey(index)) {
          sum += int.parse(list[i]['lprice']) * cart[index]!;
        }
      }
    });
    return sum;
  }

  List<Map<String, dynamic>> get items {
    return widget.naverResults.values.expand((e) => List<Map<String, dynamic>>.from(e)).toList();
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

    // 현재 cart 데이터를 변환
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

    // 기존 항목과 병합
    final mergedItems = <Map<String, dynamic>>[];

    for (var newItem in newItems) {
      final existingIndex = existingItems.indexWhere((item) =>
          item['title'] == newItem['title'] &&
          item['mallName'] == newItem['mallName']);

      if (existingIndex != -1) {
        // 동일한 상품이 이미 있으면 수량 합치기
        existingItems[existingIndex]['quantity'] += newItem['quantity'];
      } else {
        existingItems.add(newItem);
      }
    }

    // Firestore에 저장
    await docRef.set({'items': existingItems});
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
          '선물 추천 리스트',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 24, 67, 175)),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 7),
                                  minimumSize: const Size(40, 32),
                                ),
                                child: const Text('선물하기',
                                    style: TextStyle(fontSize: 15)),
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
                                  Text('${cart[index]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                  print('장바구니 버튼 클릭됨');
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        '장바구니 담기 🛍️',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
