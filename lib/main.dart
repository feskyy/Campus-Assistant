import 'package:flutter/material.dart';

void main() {
  runApp(const CampusAssistantApp());
}

class CampusAssistantApp extends StatelessWidget {
  const CampusAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Hello, Campus Assistant!')),
      ),
    );
  }
}
