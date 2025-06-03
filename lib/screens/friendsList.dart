import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/friends_provider.dart';
import '../screens/searchGift.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ AppBar 변경: Edit → 뒤로가기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "친구 목록",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.more_horiz, color: Colors.black),
                ],
              ),
            ),

            // ✅ 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: '이름으로 검색',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.mic_none),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ 친구 목록
            Expanded(
              child: FutureBuilder(
                future: friendsProvider.loadFriends(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allFriends = friendsProvider.friends;
                  final filteredFriends = allFriends.where((friend) {
                    return friend.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredFriends.isEmpty) {
                    return const Center(child: Text("해당 이름의 친구가 없습니다."));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: filteredFriends.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final friend = filteredFriends[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchGiftPage(
                                friendName: friend.name,
                                avatarPath: friend.photoUrl,
                                snsAccount: friend.sns,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(friend.photoUrl),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              friend.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}