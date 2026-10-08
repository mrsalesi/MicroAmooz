import 'package:flutter/material.dart';
import 'screens/Page01.dart';
import 'screens/Page02.dart';
import 'utility/Tools.dart';
import 'data/Auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Tools
      .init(); // این خط باید اضافه بشه - مقداردهی اولیه‌ی Dio و CookieJar
  await Auth.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Tools.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const Page01(),
    );
  }
}
