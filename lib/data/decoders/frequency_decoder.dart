import 'dart:math';

import 'package:audio_decoder/data/mapper/freq_map.dart';
import 'package:audio_decoder/data/servise/fft_service.dart';
import 'package:audio_decoder/data/servise/wav_reader.dart';

class FrequencyDecoder {
  final FFTService _fft;

  FrequencyDecoder(this._fft);

  Future<(String, List<double>, List<double>)> decode(
    WavData wav, {
    Duration toneLength = const Duration(milliseconds: 300),
    Duration gapLength = const Duration(milliseconds: 100),
    double silenceThreshold = 0.01, // RMS below this ⇒ silence
    int searchHzMin = 200,
    int searchHzMax = 800,
    double freqToleranceHz = 6.0, // allow drift
  }) async {
    final sr = wav.sampleRate;
    final samples = wav.samples;
    final toneN = (sr * toneLength.inMilliseconds / 1000).round();
    final gapN = (sr * gapLength.inMilliseconds / 1000).round();

    final chunkCenters = <int>[];
    final chunkPeaksHz = <double>[];
    final chunkRms = <double>[];

    int i = 0;
    final textBuffer = StringBuffer();

    while (i + toneN <= samples.length) {
      // Evaluate RMS to decide tone vs silence
      final rms = _rms(samples, i, toneN);
      if (rms < silenceThreshold) {
        // skip gap
        i += max(gapN, toneN ~/ 3);
        continue;
      }
      // Extract the ~300ms tone segment, get dominant frequency
      final seg = samples.sublist(i, i + toneN);
      final mags = _fft.magnitudeSpectrum(seg, sr);

      // Search within expected band
      int minBin = (searchHzMin * mags.length * 2 / sr).floor().clamp(
        0,
        mags.length - 1,
      );
      int maxBin = (searchHzMax * mags.length * 2 / sr).ceil().clamp(
        0,
        mags.length - 1,
      );

      int peakBin = minBin;
      double peakVal = -1;
      for (int b = minBin; b <= maxBin; b++) {
        final v = mags[b];
        if (v > peakVal) {
          peakVal = v;
          peakBin = b;
        }
      }
      // Parabolic interpolation around the peak for sub-bin precision
      final refinedHz = _parabolicPeakHz(mags, peakBin, sr);

      // Map to nearest dictionary frequency within tolerance
      String char = '?';
      double bestDiff = 1e9;
      for (final e in FreqMap.hzToChar.entries) {
        final diff = (refinedHz - e.key).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          char = e.value;
        }
      }
      if (bestDiff > freqToleranceHz) {
        char = '�'; // replacement char for unknown/too far
      }

      textBuffer.write(char);
      chunkCenters.add(i + toneN ~/ 2);
      chunkPeaksHz.add(refinedHz);
      chunkRms.add(rms);

      // Advance by tone + gap (approximate framing)
      i += toneN + gapN;
    }

    return (textBuffer.toString(), chunkPeaksHz, chunkRms);
  }

  double _rms(List<double> x, int off, int n) {
    double s = 0;
    for (int i = 0; i < n; i++) {
      final v = x[off + i];
      s += v * v;
    }
    return sqrt(s / n);
  }

  double _parabolicPeakHz(List<double> mags, int k, int sampleRate) {
    final n = mags.length;
    final k0 = (k - 1).clamp(0, n - 1), k2 = (k + 1).clamp(0, n - 1);
    final a = mags[k0], b = mags[k], c = mags[k2];
    double denom = (a - 2 * b + c);
    double delta = 0.0;
    if (denom.abs() > 1e-12) {
      delta =
          0.5 *
          (a - c) /
          denom; // -0.5*(a-c)/(a-2b+c) but sign consistent with our bins
    }
    final refinedBin = (k + delta);
    return refinedBin * sampleRate / (n * 2.0);
  }
}
