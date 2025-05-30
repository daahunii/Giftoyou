import 'package:flutter/material.dart';
import 'searchGift.dart';

class FriendsListPage extends StatelessWidget {
  const FriendsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> friends = [
      {"name": "Lyndsey", "avatar": "assets/lyndsey.jpg", "status": "online"},
      {"name": "Mom💝", "avatar": "assets/mom.jpg", "status": "online"},
      {"name": "Elliott", "avatar": "assets/elliott.jpg", "status": "offline"},
      {"name": "Lauren", "avatar": "assets/lauren.jpg", "status": "online"},
      {"name": "Iddris", "avatar": "assets/iddris.jpg", "status": "online"},
      {"name": "The NBHD", "avatar": "assets/nbhd.jpg", "status": "offline"},
      {"name": "Canyon Club", "avatar": "assets/canyon.jpg", "status": "offline"},
      {"name": "Tobias", "avatar": "assets/tobias.jpg", "status": "offline"},
      {"name": "Karla", "avatar": "assets/karla.jpg", "status": "online"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit", style: TextStyle(color: Colors.blue)),
                  Text("친구 목록", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      Icon(Icons.more_horiz, color: Colors.black),
                      SizedBox(width: 8),
                      Icon(Icons.edit_outlined, color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.mic_none),
                  filled: true,
                  fillColor: Color(0xFFF2F2F2),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: friends.length * 2,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final friend = friends[index % friends.length];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchGiftPage(
                            friendName: friend["name"]!,
                            avatarPath: friend["avatar"]!,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundImage: AssetImage(friend["avatar"]!),
                            ),
                            if (friend['status'] == 'online')
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          friend["name"]!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
