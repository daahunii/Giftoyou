import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  int totalPrice = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  Future<void> fetchCartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final doc = await FirebaseFirestore.instance.collection('carts').doc(uid).get();

    if (doc.exists) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data?['items'] ?? []);

      int priceSum = 0;
      for (var item in items) {
        priceSum += int.parse(item['lprice']) * ((item['quantity'] ?? 1) as int);
      }

      setState(() {
        cartItems = items;
        totalPrice = priceSum;
        isLoading = false;
      });
    } else {
      setState(() {
        cartItems = [];
        totalPrice = 0;
        isLoading = false;
      });
    }
  }

  Future<void> removeItem(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final item = cartItems[index];

    setState(() {
      totalPrice -= int.parse(item['lprice']) * ((item['quantity'] as num?)?.toInt() ?? 1);
      cartItems.removeAt(index);
    });

    await FirebaseFirestore.instance.collection('carts').doc(uid).set({
      'items': cartItems,
    });
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(price)}원';
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
        title: const Text('장바구니', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Divider(height: 1, thickness: 1),
                _buildInfoRow('배송지', 'Add shipping address'),
                _buildInfoRow('배송방법', 'Free\nStandard | 3-4 days'),
                _buildInfoRow('결제방법', 'Visa *1234'),
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('상품', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 4, child: Text('상품 정보', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('상품 가격', style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => removeItem(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['image'],
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 64,
                                    height: 64,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['mallName'] ?? '브랜드 미상',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      item['title'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text('상품 수량: ${item['quantity'].toString().padLeft(2, '0')}'),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    formatCurrency(int.parse(item['lprice'])),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildPriceRow('총 상품 금액', formatCurrency(totalPrice)),
                      _buildPriceRow('배송비', 'Free'),
                      _buildPriceRow('할인 금액', '0원'),
                      const SizedBox(height: 6),
                      _buildPriceRow('최종 금액', formatCurrency(totalPrice), bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 300,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D63D1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('선물하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(fontSize: 14), textAlign: TextAlign.end),
      onTap: () {},
    );
  }

  Widget _buildPriceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}