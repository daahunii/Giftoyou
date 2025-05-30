import 'dart:async';
import 'package:flutter/material.dart';

class SearchGiftPage extends StatefulWidget {
  final String friendName;
  final String avatarPath;

  const SearchGiftPage({
    super.key,
    required this.friendName,
    required this.avatarPath,
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

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
        _waveController.stop();
        _dotController.stop();
      });
    });

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _beginAlignAnim = Tween<Alignment>(
      begin: const Alignment(0.07, 0.75),
      end: const Alignment(-0.3, -0.3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _endAlignAnim = Tween<Alignment>(
      begin: const Alignment(0.93, 0.25),
      end: const Alignment(1.3, 1.3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFADC7FF),
                      width: 1.2,
                    ),
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
            child: Text.rich(
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
          const SizedBox(height: 10),
          if (_isLoading)
            const Text('11 mins ago', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isLoading) _buildWaveBackground(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(widget.avatarPath),
                  radius: 80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
          _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildDot(index),
                    );
                  }),
                )
              : ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/recommendList',
                    arguments: {
                      'friendName': widget.friendName,
                      'avatarPath': widget.avatarPath,
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
