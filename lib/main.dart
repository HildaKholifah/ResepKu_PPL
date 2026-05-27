import 'package:app_resepku/data/service/token_storage.dart';
import 'package:app_resepku/presentation/login_page.dart';
import 'package:app_resepku/presentation/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLogin() async {
    final token = await TokenStorage().getToken();
    return token != null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
