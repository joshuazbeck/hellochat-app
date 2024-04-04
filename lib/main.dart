import 'package:flutter/material.dart';
import 'package:palette_chat/viewmodel/chat_view_model.dart';
import 'package:palette_chat/view/home.dart';
import 'package:palette_chat/viewmodel/main_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MainViewModel()),
    ChangeNotifierProvider(create: (_) => ChatViewModel()),
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Hello Chat")),
        body: const HomePage(),
      ),
    );
  }
}
