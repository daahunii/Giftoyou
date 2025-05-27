import 'package:flutter/material.dart';

class Gift extends StatelessWidget {
  const Gift({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hi, User',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFE4F6FF),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFB7C6E6),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: Color(0xFFF69171),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Opacity(
                opacity: 0.5,
                child: Text(
                  'No:1184/A, Maruthi nag...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFFE1E1E1).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 20),
                    Icon(Icons.search, color: Colors.black45),
                    SizedBox(width: 10),
                    Text(
                      'Search anything',
                      style: TextStyle(fontSize: 18, color: Colors.black45),
                    )
                  ],
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
                              'Get 60%\nDiscount Now',
                              style: TextStyle(
                                color: Color(0xFFFED302),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '*Applicable on selective products',
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            const SizedBox(height: 10),
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
                                  '🛒 Order now',
                                  style: TextStyle(color: Colors.black),
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
                children: const [
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D63D1),
                      fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildCategory(String title, String assetPath, Color bgColor, Color textColor) {
    return SizedBox(
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
    );
  }
}
