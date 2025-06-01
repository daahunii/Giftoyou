import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/recommendList.dart';

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
      // ✅ 지역화 지원 추가
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/home': (context) => Home(),
        '/login': (context) => const Login(),
        '/recommendList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RecommendListPage(
            friendName: args['friendName'],
            avatarPath: args['avatarPath'],
            naverResults: args['naverResults'],
          );
        },
      },
    );
  }
}