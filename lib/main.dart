import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const SawApp());
}

class SawApp extends StatelessWidget {
  const SawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranking Lagu - SAW',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
