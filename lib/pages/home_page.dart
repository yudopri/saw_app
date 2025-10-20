import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/song.dart';
import '../services/csv_loader.dart';
import '../services/saw_service.dart';
import '../widgets/ranking_line_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CsvLoader csvLoader = CsvLoader();
  final SawService sawService = SawService();

  List<Song> songs = [];
  bool loading = true;
  bool ranked = false;
  String? selectedCriterion;

  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final List<Map<String, String>> criteria = [
    {'key': 'melody', 'label': 'Kualitas Melodi'},
    {'key': 'lyric', 'label': 'Kualitas Lirik'},
    {'key': 'production', 'label': 'Produksi Lagu'},
    {'key': 'price', 'label': 'Harga'},
    {'key': 'all', 'label': 'Gabungan Semua Kriteria'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await csvLoader.loadSongs();
    setState(() {
      songs = loaded;
      loading = false;
      ranked = false;
      selectedCriterion = null;
    });
  }

  void _calculateSaw() {
    setState(() {
      ranked = true;
    });
    sawService.calculate(
      songs,
      selectedCriterion: selectedCriterion == 'all' ? null : selectedCriterion,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perangkingan berdasarkan ${_getCriterionLabel()} berhasil!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  String _getCriterionLabel() {
    return criteria.firstWhere(
      (c) => c['key'] == selectedCriterion,
      orElse: () => {'label': 'Gabungan Semua Kriteria'},
    )['label']!;
  }

  String fmt(double v, [int n = 3]) => v.toStringAsFixed(n);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          ranked ? 'Hasil Perangkingan SAW' : 'Data Lagu Mentah',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.indigo[600],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTopBar(),
                if (ranked)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: RankingLineChart(songs: songs),
                      ),
                    ),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: ListView.builder(
                      key: ValueKey(ranked),
                      padding: const EdgeInsets.all(12),
                      itemCount: songs.length > 100 ? 100 : songs.length,
                      itemBuilder: (context, i) {
                        final s = songs[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: ranked
                                  ? Colors.amber[100]
                                  : Colors.indigo[100],
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo),
                              ),
                            ),
                            title: Text(
                              s.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              s.artist,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: ranked
                                ? const Icon(Icons.star, color: Colors.amber)
                                : const Icon(Icons.music_note,
                                    color: Colors.grey),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nilai Asli:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Melodi: ${s.melody}'),
                                    Text('Lirik: ${s.lyric}'),
                                    Text('Produksi: ${s.production}'),
                                    Text('Harga: ${currency.format(s.price)}'),
                                    const Divider(),
                                    const Text('Nilai Normalisasi:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'Melodi: ${fmt(s.normalized['melody'] ?? 0)}'),
                                    Text(
                                        'Lirik: ${fmt(s.normalized['lyric'] ?? 0)}'),
                                    Text(
                                        'Produksi: ${fmt(s.normalized['production'] ?? 0)}'),
                                    Text(
                                        'Harga: ${fmt(s.normalized['price'] ?? 0)}'),
                                    if (ranked) ...[
                                      const Divider(),
                                      Text(
                                          'Skor Akhir SAW: ${fmt(s.score)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo)),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            selectedCriterion == null ? null : (ranked ? _loadData : _calculateSaw),
        backgroundColor:
            selectedCriterion == null ? Colors.grey : (ranked ? Colors.redAccent : Colors.indigo),
        icon: Icon(ranked ? Icons.refresh : Icons.auto_graph),
        label: Text(ranked ? 'Kembali ke Data Mentah' : 'Hitung SAW'),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.indigo[50],
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Lagu: ${songs.length}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          DropdownButton<String>(
            value: selectedCriterion,
            hint: const Text('Pilih Kriteria'),
            items: criteria
                .map(
                  (c) => DropdownMenuItem(
                    value: c['key'],
                    child: Text(c['label']!),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() {
              selectedCriterion = v;
              ranked = false;
            }),
          ),
        ],
      ),
    );
  }
}
