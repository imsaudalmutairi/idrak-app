import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/chat_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const IdrakApp());
}

class IdrakApp extends StatelessWidget {
  const IdrakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'idrak',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const ChatScreen(),
    );
  }
}
