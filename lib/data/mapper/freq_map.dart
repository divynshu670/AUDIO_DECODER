class FreqMap {
  // Character→Frequency mapping (Hz)
  static const Map<String, int> charToHz = {
    "A": 440,
    "B": 350,
    "C": 260,
    "D": 474,
    "E": 492,
    "F": 401,
    "G": 584,
    "H": 553,
    "I": 582,
    "J": 525,
    "K": 501,
    "L": 532,
    "M": 594,
    "N": 599,
    "O": 528,
    "P": 539,
    "Q": 675,
    "R": 683,
    "S": 698,
    "T": 631,
    "U": 628,
    "V": 611,
    "W": 622,
    "X": 677,
    "Y": 688,
    "Z": 693,
    " ": 418,
  };

  static final Map<int, String> hzToChar = {
    for (final e in charToHz.entries) e.value: e.key,
  };
}
