import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class SearchGiftPage extends StatefulWidget {
  final String friendName;
  final String avatarPath;
  final String snsAccount;

  const SearchGiftPage({
    super.key,
    required this.friendName,
    required this.avatarPath,
    required this.snsAccount,
  });

  @override
  State<SearchGiftPage> createState() => _SearchGiftPageState();
}

class _SearchGiftPageState extends State<SearchGiftPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  late final AnimationController _waveController;
  late final AnimationController _dotController;
  late final AnimationController _bgController;
  late final Animation<Alignment> _beginAlignAnim;
  late final Animation<Alignment> _endAlignAnim;

  String? _downloadedAvatarUrl;
  List<String> _fetchedImages = [];
  List<String> _imageLabels = [];

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _dotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);

    _beginAlignAnim = Tween<Alignment>(
      begin: const Alignment(0.07, 0.75),
      end: const Alignment(-0.3, -0.3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _endAlignAnim = Tween<Alignment>(
      begin: const Alignment(0.93, 0.25),
      end: const Alignment(1.3, 1.3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _loadAvatarImage();
    _fetchInstagramImages();
  }

  Future<void> _loadAvatarImage() async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.avatarPath);
      final url = await ref.getDownloadURL();
      setState(() {
        _downloadedAvatarUrl = url;
      });
    } catch (e) {
      print("이미지 다운로드 실패: $e");
    }
  }

  Future<void> _fetchInstagramImages() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8080/crawl?username=${widget.snsAccount}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('🔥 서버 메시지: $message');
        setState(() {
          _fetchedImages = List<String>.from(data['images']);
        });

        await _labelStoredImagesInFirebase();

        setState(() {
          _isLoading = false;
          _waveController.stop();
          _dotController.stop();
        });
      } else {
        throw Exception('API 호출 오류: \${response.statusCode}');
      }
    } catch (e) {
      print('API 요청 실패: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("서버 연결 실패"),
            content: const Text("이미지를 불러오는 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _labelStoredImagesInFirebase() async {
    try {
      final result = await FirebaseStorage.instance
        .ref('insta_images/${widget.snsAccount}/')
        .listAll();

      final imageUrls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()),
      );

      final labels = await _getLabelsFromVision(imageUrls);

      setState(() {
        _imageLabels = labels.toSet().toList();
      });

      print("✅ 최종 라벨링 결과: $_imageLabels");
    } catch (e) {
      print("❌ Firebase 라벨링 실패: $e");
    }
  }

  /// Vision API를 호출하여 이미지 라벨링을 수행합니다.
  Future<List<String>> _getLabelsFromVision(List<String> urls) async {
    try {
      final response = await http.post(
        Uri.parse("https://labelimage-thugnd6r5a-uc.a.run.app"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"imageUrls": urls}),  // ✅ 필드명 확인
      );

      print("📤 요청된 URL 수: ${urls.length}");
      print("📤 요청 바디: ${jsonEncode({"imageUrls": urls})}");
      print("📥 응답 상태코드: ${response.statusCode}");
      print("📥 응답 바디: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data["labels"]);
      } else {
        throw Exception("라벨링 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Vision API 요청 중 예외 발생: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _dotController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        double opacity = (1 - ((index - _dotController.value * 3) % 3)).clamp(0.2, 1.0);
        return Opacity(
          opacity: opacity,
          child: const CircleAvatar(
            radius: 5,
            backgroundColor: Color(0xFFADC7FF),
          ),
        );
      },
    );
  }

  Widget _buildWaveBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final scale = 1.0 + _waveController.value + i * 0.4;
            final opacity = (1.0 - _waveController.value).clamp(0.0, 1.0);
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity * (1 - i * 0.3),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFADC7FF), width: 1.2),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Text.rich(
                key: ValueKey(_isLoading),
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.friendName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F51B5),
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: _isLoading
                          ? ' 님께 어울릴만한\n선물 탐색 중...'
                          : ' 님께 어울릴만한\n선물리스트가 나왔어요!',
                      style: const TextStyle(
                        color: Color(0xFF3F51B5),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: Container(
              key: ValueKey(_isLoading),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading) _buildWaveBackground(),
                  CircleAvatar(
                    backgroundImage: _downloadedAvatarUrl != null
                        ? NetworkImage(_downloadedAvatarUrl!)
                        : const AssetImage('assets/gift_close.png') as ImageProvider,
                    radius: 80,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: _isLoading
                ? Row(
                    key: const ValueKey(true),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildDot(index),
                      );
                    }),
                  )
                : ElevatedButton(
                    key: const ValueKey(false),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/recommendList',
                        arguments: {
                          'friendName': widget.friendName,
                          'avatarPath': widget.avatarPath,
                          'images': _fetchedImages,
                          'labels': _imageLabels,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D63D1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text(
                      '선물하기',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _beginAlignAnim.value,
                end: _endAlignAnim.value,
                colors: const [Color(0xFFF3F3F3), Color(0xFFC9F4FC)],
              ),
            ),
            child: SafeArea(child: child!),
          );
        },
        child: _buildContent(),
      ),
    );
  }
}