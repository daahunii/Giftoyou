import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/recommendList.dart';
import 'screens/calendar.dart';
import 'screens/friendsList.dart';
import 'screens/searchResult.dart';
import 'screens/categories.dart';
class GiftoYouApp extends StatelessWidget {
  const GiftoYouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiftoYou',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      locale: const Locale('ko', 'KR'), // ← 명시적 locale 설정 (중요)
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/home': (context) => const Home(),
        '/login': (context) => const Login(),
        '/calendar': (context) => const CalendarPage(),
        '/friendsList': (context) => const FriendsListPage(),
        '/searchResult': (context) {
          final keyword = ModalRoute.of(context)!.settings.arguments as String;
          return SearchResultPage(keyword: keyword);
        },
        '/recommendList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RecommendListPage(
            friendName: args['friendName'] ?? '',
            avatarPath: args['avatarPath'] ?? '',
            naverResults: args['naverResults'] ?? {},
          );
        },
        '/categories': (context) => const CategoriesPage(),
      },
    );
  }
}