import 'package:audio_decoder/presentation/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Decoder',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}
