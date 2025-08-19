import 'dart:math';

import 'package:audio_decoder/data/decoders/frequency_decoder.dart';
import 'package:audio_decoder/data/mapper/freq_map.dart';
import 'package:audio_decoder/data/servise/fft_service.dart';
import 'package:audio_decoder/data/servise/wav_reader.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to synthesize a WAV-like mono sample list which contains tones for the
/// characters in `text`. Each tone is toneLength, followed by gapLength silent samples.
List<double> synthesizeTonesForText(
  String text, {
  required int sampleRate,
  int toneMs = 300,
  int gapMs = 100,
  double amplitude = 0.8,
}) {
  final toneN = (sampleRate * toneMs / 1000).round();
  final gapN = (sampleRate * gapMs / 1000).round();
  final out = <double>[];

  for (int i = 0; i < text.length; i++) {
    final ch = text[i].toUpperCase();
    final freq = FreqMap.charToHz[ch] ?? 440;
    for (int n = 0; n < toneN; n++) {
      final t = n / sampleRate;
      out.add(amplitude * sin(2 * pi * freq * t));
    }
    // gap silence
    for (int g = 0; g < gapN; g++) {
      out.add(0.0);
    }
  }
  return out;
}

void main() {
  test('FrequencyDecoder decodes a short synthesized message', () async {
    final sr = 8000;
    final text = 'ABC';
    final samples = synthesizeTonesForText(text, sampleRate: sr);

    final wav = WavData(sampleRate: sr, samples: samples);
    final fft = FFTService();
    final decoder = FrequencyDecoder(fft);

    final (decodedText, peaks, rms) = await decoder.decode(
      wav,
      toneLength: const Duration(milliseconds: 300),
      gapLength: const Duration(milliseconds: 100),
      silenceThreshold: 0.001, // very low since synthesized amplitude is high
      searchHzMin: 200,
      searchHzMax: 800,
      freqToleranceHz: 15.0, // allow some tolerance for binning
    );

    // The decoder returns uppercase characters (via FreqMap), and unknowns as replacement.
    expect(decodedText.replaceAll('�', '?').length, text.length);
    // allow the decoded text to match characters (tolerant to replacement char)
    // For stricter test, ensure there are no replacement chars:
    expect(
      decodedText.contains('�'),
      isFalse,
      reason: 'Decoder returned replacement char(s): $decodedText',
    );

    // final check
    expect(decodedText, text);
    expect(peaks.length, text.length);
    expect(rms.length, text.length);
  });
}
