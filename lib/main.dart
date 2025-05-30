import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:giftoyou/app.dart'; // 앱 루트 위젯
import 'firebase_options.dart'; // Firebase 자동 설정 파일 (flutterfire configure)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GiftoYouApp());
}