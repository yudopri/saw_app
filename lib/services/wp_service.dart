import 'dart:math';
import '../models/song.dart';

class WpService {
  // Bobot asli dari setiap kriteria
  final Map<String, double> originalWeights = {
    'melody': 0.35,
    'lyric': 0.30,
    'production': 0.25,
    'price': 0.10, // cost criterion
  };

  // Bobot ternormalisasi (W / ΣW)
  Map<String, double> normalizedWeights = {};

  /// Fungsi utama untuk menghitung Weighted Product
  void calculate(List<Song> songs, {String? selectedCriterion}) {
    if (songs.isEmpty) return;

    // LANGKAH 1: Normalisasi Bobot
    _normalizeWeights(selectedCriterion);

    // LANGKAH 2: Cari nilai max dan min untuk normalisasi data
    double maxMelody = songs.map((s) => s.melody).reduce(max);
    double maxLyric = songs.map((s) => s.lyric).reduce(max);
    double maxProduction = songs.map((s) => s.production).reduce(max);
    double minPrice = songs.map((s) => s.price).reduce(min);

    // LANGKAH 3: Hitung Vektor S untuk setiap alternatif
    for (var s in songs) {
      // Normalisasi nilai (benefit: xi/max, cost: min/xi)
      double nMelody = s.melody / maxMelody;
      double nLyric = s.lyric / maxLyric;
      double nProduction = s.production / maxProduction;
      double nPrice = minPrice / s.price; // cost criterion

      s.normalized = {
        'melody': nMelody,
        'lyric': nLyric,
        'production': nProduction,
        'price': nPrice,
      };

      // Hitung Vektor S = Π(xi^wi)
      // S = (melody^w1) × (lyric^w2) × (production^w3) × (price^w4)
      if (selectedCriterion != null && normalizedWeights.containsKey(selectedCriterion)) {
        // Jika filter kriteria, hanya gunakan kriteria tersebut
        s.vectorS = pow(
            s.normalized[selectedCriterion]!,
            normalizedWeights[selectedCriterion]!
        ).toDouble();
      } else {
        // Gunakan semua kriteria
        // Casting setiap pow() ke double
        double powMelody = pow(nMelody, normalizedWeights['melody']!).toDouble();
        double powLyric = pow(nLyric, normalizedWeights['lyric']!).toDouble();
        double powProduction = pow(nProduction, normalizedWeights['production']!).toDouble();
        double powPrice = pow(nPrice, normalizedWeights['price']!).toDouble();

        s.vectorS = powMelody * powLyric * powProduction * powPrice;
      }
    }

    // LANGKAH 4: Hitung total S untuk menghitung V
    double totalS = songs.fold(0.0, (sum, s) => sum + s.vectorS);

    // LANGKAH 5: Hitung Vektor V untuk setiap alternatif
    for (var s in songs) {
      // V = S / ΣS
      s.vectorV = totalS > 0 ? s.vectorS / totalS : 0;
      s.score = s.vectorV; // Gunakan V sebagai score untuk ranking
    }

    // LANGKAH 6: Urutkan berdasarkan V (tertinggi = terbaik)
    songs.sort((a, b) => b.vectorV.compareTo(a.vectorV));
  }

  /// Fungsi untuk normalisasi bobot (W / ΣW)
  void _normalizeWeights(String? selectedCriterion) {
    if (selectedCriterion != null && originalWeights.containsKey(selectedCriterion)) {
      // Jika ada filter, set bobot hanya untuk kriteria tersebut
      double weight = originalWeights[selectedCriterion]!;
      normalizedWeights = {
        selectedCriterion: weight / weight, // = 1.0
      };
    } else {
      // Normalisasi semua bobot: wi' = wi / Σw
      double totalWeight = originalWeights.values.reduce((a, b) => a + b);
      normalizedWeights = originalWeights.map(
              (key, value) => MapEntry(key, value / totalWeight)
      );
    }
  }

  /// Getter untuk mendapatkan bobot yang dinormalisasi (untuk UI jika diperlukan)
  Map<String, double> getNormalizedWeights() => normalizedWeights;
}