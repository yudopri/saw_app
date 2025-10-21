import 'dart:math';
import '../models/song.dart';

class SawService {
  final Map<String, double> weights = {
    'melody': 0.35,
    'lyric': 0.30,
    'production': 0.25,
    'price': 0.10, // cost criterion
  };

  void calculate(List<Song> songs, {String? selectedCriterion}) {
    if (songs.isEmpty) return;

    double maxMelody = songs.map((s) => s.melody).reduce(max);
    double maxLyric = songs.map((s) => s.lyric).reduce(max);
    double maxProduction = songs.map((s) => s.production).reduce(max);
    double minPrice = songs.map((s) => s.price).reduce(min);

    for (var s in songs) {
      double nMelody = s.melody / maxMelody;
      double nLyric = s.lyric / maxLyric;
      double nProduction = s.production / maxProduction;
      double nPrice = minPrice / s.price;

      s.normalized = {
        'melody': nMelody,
        'lyric': nLyric,
        'production': nProduction,
        'price': nPrice,
      };

      // Jika ada filter, hanya kriteria itu yang dipakai.
      if (selectedCriterion != null && weights.containsKey(selectedCriterion)) {
        s.score = s.normalized[selectedCriterion]! * weights[selectedCriterion]!;
      } else {
        s.score = (nMelody * weights['melody']!) +
            (nLyric * weights['lyric']!) +
            (nProduction * weights['production']!) +
            (nPrice * weights['price']!);
      }
    }

    songs.sort((a, b) => b.score.compareTo(a.score));
  }
}

