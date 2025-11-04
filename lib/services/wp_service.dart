import 'dart:math';
import '../models/song.dart';

class WpService {
  // Bobot asli dari setiap kriteria
  final Map<String, double> originalWeights = {
    'popularity': 0.25,
    'danceability': 0.20,
    'energy': 0.20,
    'acousticness': 0.10, // cost criterion
    'duration': 0.10, // cost criterion
    'valence': 0.15,
  };

  // Bobot ternormalisasi (W / ΣW)
  Map<String, double> normalizedWeights = {};

  /// Fungsi utama untuk menghitung Weighted Product
  void calculate(List<Song> songs, {String? selectedCriterion}) {
    if (songs.isEmpty) return;

    // LANGKAH 1: Normalisasi Bobot
    _normalizeWeights(selectedCriterion);

    // LANGKAH 2: Cari nilai max dan min untuk normalisasi data
    double maxPopularity = songs.map((s) => s.popularity).reduce(max);
    double maxDanceability = songs.map((s) => s.danceability).reduce(max);
    double maxEnergy = songs.map((s) => s.energy).reduce(max);
    double minAcousticness = songs.map((s) => s.acousticness).reduce(min);
    double minDuration = songs.map((s) => s.duration).reduce(min);
    double maxValence = songs.map((s) => s.valence).reduce(max);

    // LANGKAH 3: Hitung Vektor S untuk setiap alternatif
    for (var s in songs) {
      // Normalisasi nilai (benefit: xi/max, cost: min/xi)
      double nPopularity = s.popularity / maxPopularity;
      double nDanceability = s.danceability / maxDanceability;
      double nEnergy = s.energy / maxEnergy;
      double nAcousticness = minAcousticness / s.acousticness; // cost criterion
      double nDuration = minDuration / s.duration; // cost criterion
      double nValence = s.valence / maxValence;

      s.normalized = {
        'popularity': nPopularity,
        'danceability': nDanceability,
        'energy': nEnergy,
        'acousticness': nAcousticness,
        'duration': nDuration,
        'valence': nValence,
      };

      // Hitung Vektor S = Π(xi^wi)
      if (selectedCriterion != null && normalizedWeights.containsKey(selectedCriterion)) {
        // Jika filter kriteria, hanya gunakan kriteria tersebut
        s.vectorS = pow(
            s.normalized[selectedCriterion]!,
            normalizedWeights[selectedCriterion]!
        ).toDouble();
      } else {
        // Gunakan semua kriteria
        // Casting setiap pow() ke double
        double powPopularity = pow(nPopularity, normalizedWeights['popularity']!).toDouble();
        double powDanceability = pow(nDanceability, normalizedWeights['danceability']!).toDouble();
        double powEnergy = pow(nEnergy, normalizedWeights['energy']!).toDouble();
        double powAcousticness = pow(nAcousticness, normalizedWeights['acousticness']!).toDouble();
        double powDuration = pow(nDuration, normalizedWeights['duration']!).toDouble();
        double powValence = pow(nValence, normalizedWeights['valence']!).toDouble();

        s.vectorS = powPopularity * powDanceability * powEnergy * powAcousticness * powDuration * powValence;
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