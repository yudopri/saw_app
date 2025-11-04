import 'package:flutter/services.dart' show rootBundle;
import '../models/song.dart';

class CsvLoader {
  Future<List<Song>> loadSongs() async {
    final raw = await rootBundle.loadString('assets/spotify_songs.csv');
    final lines = raw.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Hilangkan header (baris pertama)
    final dataLines = lines.skip(1);

    return dataLines.map((line) {
      final fields = line.split(',').map((e) => e.trim()).toList();
      return Song.fromCsv(fields);
    }).toList();
  }
}
