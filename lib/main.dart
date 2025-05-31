import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // provider 패키지
import 'package:giftoyou/app.dart'; // 앱 루트 위젯
import 'firebase_options.dart'; // Firebase 자동 설정 파일
import 'package:giftoyou/provider/friends_provider.dart'; // 친구 Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        // 여기에 추가적으로 필요한 Provider들 확장 가능
      ],
      child: const GiftoYouApp(),
    ),
  );
}