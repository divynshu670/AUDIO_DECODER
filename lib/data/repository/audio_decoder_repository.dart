import 'package:audio_decoder/domain/entity/decoded_message.dart';

abstract class AudioDecoderRepository {
  /// Decodes the embedded message from a WAV asset.
  Future<DecodedMessage> decodeFromAsset(String assetPath);
}
