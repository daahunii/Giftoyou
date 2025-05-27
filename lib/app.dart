import 'package:flutter/material.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/login.dart';

class GiftoYouApp extends StatelessWidget {
  const GiftoYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiftoYou',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard', // 원하는 폰트로 설정
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/home': (context) => Home(),
        '/login': (context) => const Login(),
      },
    );
  }
}