import 'package:audio_decoder/data/repository/audio_decoder_repository.dart';
import 'package:audio_decoder/domain/entity/decoded_message.dart';

class DecodeAudioMessage {
  final AudioDecoderRepository repo;
  DecodeAudioMessage(this.repo);

  Future<DecodedMessage> call(String assetPath) {
    return repo.decodeFromAsset(assetPath);
  }
}
