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
                  const Text('Nilai Asli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  Text('Melodi: ${song.melody}'),
                  Text('Lirik: ${song.lyric}'),
                  Text('Produksi: ${song.production}'),
                  Text('Harga: ${currency.format(song.price)}'),
                  const SizedBox(height: 20),

                  if (ranked) ...[
                    const Text('Nilai Normalisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text('Melodi: ${fmt(song.normalized['melody'] ?? 0)}'),
                    Text('Lirik: ${fmt(song.normalized['lyric'] ?? 0)}'),
                    Text('Produksi: ${fmt(song.normalized['production'] ?? 0)}'),
                    Text('Harga: ${fmt(song.normalized['price'] ?? 0)}'),
                    const SizedBox(height: 20),
                    const Text('Perhitungan Skor Akhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text('Skor Akhir SAW: ${fmt(song.score)}',
                        style: const TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text('Formula SAW:'),
                    const SizedBox(height: 6),
                    Text(
                        'Skor = (Melodi * 0.35) + (Lirik * 0.30) + (Produksi * 0.25) + (Harga * 0.10)',
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
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
