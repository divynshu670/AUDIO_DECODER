import 'package:audio_decoder/data/decoders/frequency_decoder.dart';
import 'package:audio_decoder/data/repository/audio_decoder_repository_impl.dart';
import 'package:audio_decoder/data/servise/audio_play_service.dart';
import 'package:audio_decoder/data/servise/fft_service.dart';
import 'package:audio_decoder/data/servise/wav_reader.dart';
import 'package:audio_decoder/domain/entity/decoded_message.dart';
import 'package:audio_decoder/domain/usecase/decode_audio_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _wavReaderProvider = Provider((ref) => WavReader());
final _fftProvider = Provider((ref) => FFTService());
final _freqDecoderProvider = Provider(
  (ref) => FrequencyDecoder(ref.read(_fftProvider)),
);

final _repoProvider = Provider(
  (ref) => AudioDecoderRepositoryImpl(
    wavReader: ref.read(_wavReaderProvider),
    frequencyDecoder: ref.read(_freqDecoderProvider),
  ),
);

final audioPlayerServiceProvider = Provider((ref) => AudioPlayerService());

final decodeUseCaseProvider = Provider(
  (ref) => DecodeAudioMessage(ref.read(_repoProvider)),
);

class DecodeState {
  final bool loading;
  final DecodedMessage? result;
  final String? error;

  const DecodeState._({required this.loading, this.result, this.error});
  const DecodeState.initial() : this._(loading: false);
  const DecodeState.loading() : this._(loading: true);
  const DecodeState.data(DecodedMessage r) : this._(loading: false, result: r);
  const DecodeState.error(String e) : this._(loading: false, error: e);
}

class DecodeController extends StateNotifier<DecodeState> {
  final DecodeAudioMessage _usecase;
  DecodeController(this._usecase) : super(const DecodeState.initial());

  Future<void> decode(String assetPath) async {
    state = const DecodeState.loading();
    try {
      final r = await _usecase(assetPath);
      state = DecodeState.data(r);
    } catch (e) {
      state = DecodeState.error(e.toString());
    }
  }
}

final decodeControllerProvider =
    StateNotifierProvider<DecodeController, DecodeState>(
      (ref) => DecodeController(ref.read(decodeUseCaseProvider)),
    );
