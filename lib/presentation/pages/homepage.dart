import 'package:audio_decoder/presentation/provider/decode_providers.dart';
import 'package:audio_decoder/presentation/widgets/spectrum_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Future<void> _loadAndDecode() async {
    // Decode
    await ref
        .read(decodeControllerProvider.notifier)
        .decode('assets/hidden_message.wav');
  }

  Future<void> _loadWavOnly() async {
    // For drawing waveform (optional)
  }

  @override
  void initState() {
    super.initState();
    _loadWavOnly();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decodeControllerProvider);
    final audioService = ref.read(audioPlayerServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Decoder'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.audiotrack_rounded, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Decode Message',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Embedde decoder',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: state.loading ? null : _loadAndDecode,
                          icon: const Icon(Icons.playlist_play),
                          label: Text(state.loading ? 'Decoding…' : 'Decode'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await audioService.playAsset(
                              'assets/hidden_message.wav',
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await audioService.stop();
                            setState(() {});
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.error != null)
              Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            if (state.result != null) ...[
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Decoded message:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        state.result!.text,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      const Text('Frequency (Hz)'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ChunkSpectrum(
                          freqs: state.result!.chunkFrequencies,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
