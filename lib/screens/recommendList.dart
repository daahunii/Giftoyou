import 'package:flutter/material.dart';
import 'package:giftoyou/screens/home.dart';

class RecommendListPage extends StatefulWidget {
  const RecommendListPage({super.key});

  @override
  State<RecommendListPage> createState() => _RecommendListPageState();
}

class _RecommendListPageState extends State<RecommendListPage> {
  final List<Map<String, dynamic>> items = [
    {
      'name': 'Carrot',
      'desc': '4 Pieces',
      'price': 40,
      'original': 65,
      'image': 'assets/carrot.png',
    },
    {
      'name': 'Beetroot',
      'desc': '500 Gms',
      'price': 90,
      'original': 115,
      'image': 'assets/beetroot.png',
    },
    {
      'name': 'Cauliflower',
      'desc': '300 Gms',
      'price': 80,
      'original': 95,
      'image': 'assets/cauliflower.png',
    },
    {
      'name': 'Cabbage',
      'desc': '1 Piece',
      'price': 85,
      'original': 115,
      'image': 'assets/cabbage.png',
    },
    {
      'name': 'Purple cab..',
      'desc': '4 Pieces',
      'price': 70,
      'original': 90,
      'image': 'assets/purple.png',
    },
    {
      'name': 'Ginger',
      'desc': '120 Gms',
      'price': 60,
      'original': 80,
      'image': 'assets/ginger.png',
    },
  ];

  final Map<int, int> cart = {}; // item index -> quantity

  int get totalItemCount => cart.values.fold(0, (a, b) => a + b);
  int get totalPrice => cart.entries.fold(0, (sum, e) => sum + e.value * items[e.key]['price'] as int);

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
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
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
                      Image.asset(item['image'], height: 80, fit: BoxFit.contain),
                      const SizedBox(height: 10),
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(item['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '\$${item['original']}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      quantity == 0
                          ? ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  cart[index] = 1;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDCF0FA),
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              ),
                              child: const Text('ADD'),
                            )
                          : Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
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
                                  onPressed: () {
                                    setState(() {
                                      cart[index] = cart[index]! + 1;
                                    });
                                  },
                                ),
                              ],
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
            bottom: 32, // 🔼 하단에서 좀 더 위로
            child: Container(
              height: 60, // 🔼 세로폭 늘림
              decoration: BoxDecoration(
                color: const Color(0xFF0D63D1),
                borderRadius: BorderRadius.circular(32),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalItemCount item | \$${totalPrice}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // 🔼 보기 좋게 폰트 약간 키움
                    ),
                  ),
                  const Text(
                    'VIEW CART 🛍️',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // 🔼 동일하게 맞춤
                    ),
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