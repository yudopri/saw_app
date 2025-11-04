import 'dart:math';
import '../models/song.dart';

class SawService {
  final Map<String, double> weights = {
    'popularity': 0.25,
    'danceability': 0.20,
    'energy': 0.20,
    'acousticness': 0.10, // cost criterion
    'duration': 0.10, // cost criterion
    'valence': 0.15,
  };

  void calculate(List<Song> songs, {String? selectedCriterion}) {
    if (songs.isEmpty) return;

    double maxPopularity = songs.map((s) => s.popularity).reduce(max);
    double maxDanceability = songs.map((s) => s.danceability).reduce(max);
    double maxEnergy = songs.map((s) => s.energy).reduce(max);
    double minAcousticness = songs.map((s) => s.acousticness).reduce(min);
    double minDuration = songs.map((s) => s.duration).reduce(min);
    double maxValence = songs.map((s) => s.valence).reduce(max);

    for (var s in songs) {
      double nPopularity = s.popularity / maxPopularity;
      double nDanceability = s.danceability / maxDanceability;
      double nEnergy = s.energy / maxEnergy;
      double nAcousticness = minAcousticness / s.acousticness;
      double nDuration = minDuration / s.duration;
      double nValence = s.valence / maxValence;

      s.normalized = {
        'popularity': nPopularity,
        'danceability': nDanceability,
        'energy': nEnergy,
        'acousticness': nAcousticness,
        'duration': nDuration,
        'valence': nValence,
      };

      // Jika ada filter, hanya kriteria itu yang dipakai.
      if (selectedCriterion != null && weights.containsKey(selectedCriterion)) {
        s.score = s.normalized[selectedCriterion]! * weights[selectedCriterion]!;
      } else {
        s.score = (nPopularity * weights['popularity']!) +
            (nDanceability * weights['danceability']!) +
            (nEnergy * weights['energy']!) +
            (nAcousticness * weights['acousticness']!) +
            (nDuration * weights['duration']!) +
            (nValence * weights['valence']!);
      }
    }

    songs.sort((a, b) => b.score.compareTo(a.score));
  }
}

