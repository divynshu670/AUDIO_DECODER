import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class WavData {
  final int sampleRate;
  final List<double> samples; // normalized [-1,1] mono
  WavData({required this.sampleRate, required this.samples});
}

class WavReader {
  Future<WavData> loadWavFromAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final data = bytes.buffer.asUint8List();

    // Parse RIFF header
    // [0..3] 'RIFF', [8..11] 'WAVE'
    String tag(int offset, int len) =>
        String.fromCharCodes(data.sublist(offset, offset + len));
    if (tag(0, 4) != 'RIFF' || tag(8, 4) != 'WAVE') {
      throw FormatException('Not a WAV file (RIFF/WAVE missing)');
    }

    int cursor = 12;
    int? sampleRate;
    int? bitsPerSample;
    int? numChannels;
    int? dataOffset;
    int? dataLength;

    // Iterate chunks
    while (cursor + 8 <= data.length) {
      final chunkId = tag(cursor, 4);
      final chunkSize = _leUint32(data, cursor + 4);
      final chunkDataStart = cursor + 8;

      if (chunkId == 'fmt ') {
        final audioFormat = _leUint16(data, chunkDataStart + 0);
        numChannels = _leUint16(data, chunkDataStart + 2);
        sampleRate = _leUint32(data, chunkDataStart + 4);
        // final byteRate = _leUint32(data, chunkDataStart + 8);
        // final blockAlign = _leUint16(data, chunkDataStart + 12);
        bitsPerSample = _leUint16(data, chunkDataStart + 14);
        if (audioFormat != 1) {
          throw UnsupportedError('Only PCM (format 1) supported');
        }
      } else if (chunkId == 'data') {
        dataOffset = chunkDataStart;
        dataLength = chunkSize;
      }

      cursor = chunkDataStart + chunkSize;
      if (cursor.isOdd) cursor++; // alignment
    }

    if (sampleRate == null ||
        bitsPerSample == null ||
        numChannels == null ||
        dataOffset == null ||
        dataLength == null) {
      throw FormatException('Incomplete WAV headers');
    }
    if (bitsPerSample != 16) {
      throw UnsupportedError('Only 16-bit PCM supported');
    }

    final bytesPerSample = bitsPerSample ~/ 8;
    final totalSamples = dataLength ~/ bytesPerSample;
    final frames = totalSamples ~/ numChannels;

    final out = List<double>.filled(frames, 0.0);
    int idx = 0;
    for (int i = 0; i < frames; i++) {
      double sum = 0;
      for (int ch = 0; ch < numChannels; ch++) {
        final offs = dataOffset + (i * numChannels + ch) * 2;
        final s = _leInt16(data, offs);
        sum += s / 32768.0;
      }
      out[idx++] = sum / numChannels;
    }

    return WavData(sampleRate: sampleRate, samples: out);
  }

  int _leUint16(Uint8List b, int o) => b[o] | (b[o + 1] << 8);
  int _leUint32(Uint8List b, int o) =>
      b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24);
  int _leInt16(Uint8List b, int o) {
    int v = b[o] | (b[o + 1] << 8);
    if (v & 0x8000 != 0) v = v - 0x10000;
    return v;
  }
}
