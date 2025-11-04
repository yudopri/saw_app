import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/song.dart';

class SongDetailPage extends StatelessWidget {
  final Song song;
  final bool ranked;

  SongDetailPage({super.key, required this.song, required this.ranked});

  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  String fmt(double v, [int n = 4]) => v.toStringAsFixed(n);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        backgroundColor: Colors.indigo,
        elevation: 2,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(song.artist,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ),
                  const SizedBox(height: 20),
                  const Text('📊 Nilai Asli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  Text('Tingkat Popularitas: ${song.popularity}'),
                  Text('Kesesuaian untuk Menari: ${song.danceability}'),
                  Text('Tingkat Energi: ${song.energy}'),
                  Text('Tingkat Akustik: ${song.acousticness}'),
                  Text('Lama Durasi: ${(song.duration / 1000).toStringAsFixed(2)} detik'),
                  Text('Tingkat Kegembiraan: ${song.valence}'),
                  const SizedBox(height: 20),

                  if (ranked) ...[
                    const Text('🧮 Nilai Ternormalisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text('Popularitas: ${fmt(song.normalized['popularity'] ?? 0)}'),
                    Text('Kesesuaian untuk Menari: ${fmt(song.normalized['danceability'] ?? 0)}'),
                    Text('Tingkat Energi: ${fmt(song.normalized['energy'] ?? 0)}'),
                    Text('Tingkat Akustik: ${fmt(song.normalized['acousticness'] ?? 0)}'),
                    Text('Lama Durasi: ${fmt(song.normalized['duration'] ?? 0)}'),
                    Text('Tingkat Kegembiraan: ${fmt(song.normalized['valence'] ?? 0)}'),
                    const SizedBox(height: 20),

                    const Text('✨ Perhitungan Metode Weighted Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text('Vektor S (Nilai Preferensi): ${fmt(song.vectorS)}',
                        style: const TextStyle(
                            color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Vektor V (Preferensi Relatif): ${fmt(song.vectorV)}',
                        style: const TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text('📐 Rumus Weighted Product:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                        'S = (Popularitas^0.25) × (Kesesuaian Menari^0.20) × (Energi^0.20) × (Akustik^0.10) × (Durasi^0.10) × (Kegembiraan^0.15)',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    const Text(
                        'V = S / ΣS (Total Semua S)',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 10),
                    const Text('💡 Penjelasan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const Text(
                        '• Vektor S = Hasil perkalian pangkat dari semua nilai yang sudah dinormalisasi',
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const Text(
                        '• Vektor V = Preferensi relatif (nilai S dibagi dengan total semua S)',
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const Text(
                        '• Lagu terbaik = Lagu dengan nilai V paling tinggi',
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}