class Song {
  final String title;
  final String artist;
  final double popularity;
  final double danceability;
  final double energy;
  final double acousticness;
  final double duration;
  final double valence;

  double score = 0;           // Akan diisi dengan vectorV untuk ranking
  double vectorS = 0;         // Nilai S dari Weighted Product
  double vectorV = 0;         // Nilai V dari Weighted Product (preferensi relatif)
  Map<String, double> normalized = {};

  Song({
    required this.title,
    required this.artist,
    required this.popularity,
    required this.danceability,
    required this.energy,
    required this.acousticness,
    required this.duration,
    required this.valence,
  });

  factory Song.fromCsv(List<String> fields) {
    return Song(
      title: fields[0],
      artist: fields[1],
      popularity: double.parse(fields[2]),
      danceability: double.parse(fields[3]),
      energy: double.parse(fields[4]),
      acousticness: double.parse(fields[5]),
      duration: double.parse(fields[6]),
      valence: double.parse(fields[7]),
    );
  }
}