## Approach
- Parse WAV (PCM 16-bit) → normalize to mono.
- Slide over audio using 300ms tone windows separated by 100ms gaps.
- For each tone window apply Hann window + radix-2 FFT.
- Find dominant bin (with parabolic interpolation).
- Map nearest frequency to a character using the provided dictionary (±6 Hz tolerance).

## Clean Architecture
- Domain: entities (DecodedMessage, FreqMap), use case (DecodeAudioMessage), and repository contract.
- Data: WAV parsing (WavReader), FFT (FFTService), frequency decoding (FrequencyDecoder), repo impl.
- Presentation: Riverpod state (DecodeController + providers), UI (HomePage) + bonus visualizers.

## Limitations
- Only PCM 16-bit WAV supported in this minimal build.
- If tones deviate by >±6 Hz or durations differ markedly from 300ms/100ms, you may need to widen tolerance or add onset detection.
- Very noisy recordings may require better denoising or a narrower search band per letter.

## How to run
- Put your audio at assets/audio/hidden_message.wav.
- Add the assets to pubspec.yaml.
- flutter pub get
- flutter run

 



