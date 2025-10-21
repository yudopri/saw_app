class Song {
  final String title;
  final String artist;
  final double melody;
  final double lyric;
  final double production;
  final double price;

  double score = 0;           // Akan diisi dengan vectorV untuk ranking
  double vectorS = 0;         // Nilai S dari Weighted Product
  double vectorV = 0;         // Nilai V dari Weighted Product (preferensi relatif)
  Map<String, double> normalized = {};

  Song({
    required this.title,
    required this.artist,
    required this.melody,
    required this.lyric,
    required this.production,
    required this.price,
  });

  factory Song.fromCsv(List<String> fields) {
    return Song(
      title: fields[0],
      artist: fields[1],
      melody: double.parse(fields[2]),
      lyric: double.parse(fields[3]),
      production: double.parse(fields[4]),
      price: double.parse(fields[5]),
    );
  }
}