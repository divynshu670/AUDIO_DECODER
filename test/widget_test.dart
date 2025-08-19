// test/widget_smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:audio_decoder/main.dart';

void main() {
  testWidgets('App Test', (WidgetTester tester) async {
    // Wrap in ProviderScope for Riverpod
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Basic sanity: the widget tree renders at least one MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);

    // Optionally assert something stable in your UI (title, a button, etc.)
    // expect(find.text('Audio Decoder'), findsOneWidget);
  });
}
