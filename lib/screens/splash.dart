import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // 2초 후에 /home으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.07, 0.75),
              end: Alignment(0.93, 0.25),
              colors: [Color(0xFFF3F3F3), Color(0xFFC9F4FC)],
            ),
          ),
          child: Stack(
            children: [
              // Gift Box
              Positioned(
                left: width * 0.07,
                top: height * 0.49,
                child: Container(
                  width: width * 0.87,
                  height: width * 0.87,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/giftbox.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // G
              Positioned(
                left: 0,
                top: height * 0.28,
                child: Container(
                  width: width * 0.38,
                  height: height * 0.15,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/G.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // I
              Positioned(
                left: width * 0.26,
                top: height * 0.25,
                child: Container(
                  width: width * 0.28,
                  height: height * 0.13,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/I.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // F
              Positioned(
                left: width * 0.48,
                top: height * 0.30,
                child: Container(
                  width: width * 0.28,
                  height: height * 0.12,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/F.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // T
              Positioned(
                left: width * 0.66,
                top: height * 0.24,
                child: Container(
                  width: width * 0.32,
                  height: height * 0.18,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/T.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // T-2
              Positioned(
                left: width * 0.29,
                top: height * 0.43,
                child: Container(
                  width: width * 0.27,
                  height: height * 0.14,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/T-2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // O
              Positioned(
                left: width * 0.50,
                top: height * 0.45,
                child: Container(
                  width: width * 0.26,
                  height: height * 0.11,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/O.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}