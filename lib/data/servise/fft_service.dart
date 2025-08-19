import 'dart:math';

class Complex {
  double re, im;
  Complex(this.re, this.im);
}

class FFTService {
  // In-place radix-2 Cooley–Tukey FFT
  void fft(List<Complex> a) {
    final n = a.length;
    if (n == 0 || (n & (n - 1)) != 0) {
      throw ArgumentError('FFT length must be power of 2');
    }
    // bit-reversal
    int j = 0;
    for (int i = 1; i < n; i++) {
      int bit = n >> 1;
      for (; (j & bit) != 0; bit >>= 1) {
        j &= ~bit;
      }
      j |= bit;
      if (i < j) {
        final tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
      }
    }
    // butterflies
    for (int len = 2; len <= n; len <<= 1) {
      final ang = -2 * pi / len;
      final wlen = Complex(cos(ang), sin(ang));
      for (int i = 0; i < n; i += len) {
        var w = Complex(1, 0);
        for (int k = 0; k < len ~/ 2; k++) {
          final u = a[i + k];
          final v = _mul(a[i + k + len ~/ 2], w);
          a[i + k] = Complex(u.re + v.re, u.im + v.im);
          a[i + k + len ~/ 2] = Complex(u.re - v.re, u.im - v.im);
          w = _mul(w, wlen);
        }
      }
    }
  }

  Complex _mul(Complex a, Complex b) =>
      Complex(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);

  List<double> hannWindow(int n) {
    final w = List<double>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      w[i] = 0.5 * (1 - cos(2 * pi * i / (n - 1)));
    }
    return w;
  }

  /// Returns magnitude spectrum (size N/2) & binToHz helper.
  List<double> magnitudeSpectrum(List<double> signal, int sampleRate) {
    final n = _nextPow2(signal.length);
    final window = hannWindow(n);
    final a = List<Complex>.generate(
      n,
      (i) => Complex(i < signal.length ? signal[i] * window[i] : 0, 0),
    );
    fft(a);
    final mags = List<double>.filled(n ~/ 2, 0);
    for (int i = 0; i < mags.length; i++) {
      mags[i] = sqrt(a[i].re * a[i].re + a[i].im * a[i].im);
    }
    return mags;
  }

  int _nextPow2(int x) {
    var n = 1;
    while (n < x) {
      n <<= 1;
    }
    return n;
  }
}
