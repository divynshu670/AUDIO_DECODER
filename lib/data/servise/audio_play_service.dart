import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Play an asset WAV - path should be like 'assets/hidden_message.wav'
  Future<void> playAsset(String assetPath) async {
    // audioplayers AssetSource expects the filename relative to assets root.
    // If you keep full path 'assets/hidden_message.wav', strip 'assets/' prefix.
    final filename = assetPath.replaceFirst("assets/", "");
    // stop any existing playback
    await _player.stop();
    _isPlaying = true;
    // Play from assets
    await _player.play(AssetSource(filename));
    // listen for finished to update state
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
