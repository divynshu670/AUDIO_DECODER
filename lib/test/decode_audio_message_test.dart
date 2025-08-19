import 'package:audio_decoder/data/repository/audio_decoder_repository.dart';
import 'package:audio_decoder/domain/entity/decoded_message.dart';
import 'package:audio_decoder/domain/usecase/decode_audio_message.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements AudioDecoderRepository {
  final DecodedMessage value;
  FakeRepo(this.value);

  @override
  Future<DecodedMessage> decodeFromAsset(String assetPath) async {
    return value;
  }
}

void main() {
  test('DecodeAudioMessage returns decoded message from repo', () async {
    final expected = DecodedMessage(
      text: 'HELLO',
      chunkFrequencies: [440, 492],
    );
    final repo = FakeRepo(expected);
    final usecase = DecodeAudioMessage(repo);

    final r = await usecase('assets/hidden_message.wav');
    expect(r.text, expected.text);
    expect(r.chunkFrequencies, expected.chunkFrequencies);
  });
}
