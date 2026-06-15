import 'package:flutter/material.dart';
import 'package:pabelo/provider/buddy_provider.dart';
import 'package:pabelo/provider/story_provider.dart';
import 'package:pabelo/provider/tts_provider.dart';
import 'package:pabelo/screen/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TtsProvider()),
        ChangeNotifierProvider(create: (context) => StoryProvider()),
        ChangeNotifierProvider(create: (context) => BuddyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
