import 'package:audio_decoder/data/decoders/frequency_decoder.dart';
import 'package:audio_decoder/data/repository/audio_decoder_repository.dart';
import 'package:audio_decoder/data/servise/wav_reader.dart';
import 'package:audio_decoder/domain/entity/decoded_message.dart';

class AudioDecoderRepositoryImpl implements AudioDecoderRepository {
  final WavReader wavReader;
  final FrequencyDecoder frequencyDecoder;

  AudioDecoderRepositoryImpl({
    required this.wavReader,
    required this.frequencyDecoder,
  });

  @override
  Future<DecodedMessage> decodeFromAsset(String assetPath) async {
    final wav = await wavReader.loadWavFromAsset(assetPath);
    final (text, peaks, rms) = await frequencyDecoder.decode(wav);
    return DecodedMessage(text: text, chunkFrequencies: peaks);
  }
}
