class DecodedMessage {
  final String text;
  final List<double> chunkFrequencies; // dominant freq per chunk (Hz)
  const DecodedMessage({required this.text, required this.chunkFrequencies});
}
