import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/song.dart';
import '../services/csv_loader.dart';
import '../services/saw_service.dart';
import '../widgets/ranking_chart_saw.dart';

class SawPage extends StatefulWidget {
  const SawPage({super.key});

  @override
  State<SawPage> createState() => _SawPageState();
}

class _SawPageState extends State<SawPage> {
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
          'Perangkingan SAW berdasarkan ${_getCriterionLabel()} berhasil!',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          ranked ? 'Hasil Perangkingan SAW' : 'Data Lagu Mentah (SAW)',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF2563EB), // Blue untuk SAW
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFormulaCard(),
                        if (ranked) _buildChartCard(),
                        _buildSongList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            selectedCriterion == null ? null : (ranked ? _loadData : _calculateSaw),
        backgroundColor:
            selectedCriterion == null ? Colors.grey : (ranked ? const Color(0xFFE91E63) : const Color(0xFF2563EB)),
        foregroundColor: Colors.white,
        icon: Icon(ranked ? Icons.refresh : Icons.calculate),
        label: Text(
          ranked ? 'Kembali ke Data Mentah' : 'Hitung SAW',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.library_music, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Total Lagu: ${songs.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  )),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedCriterion,
              hint: Text('Pilih Kriteria',
                  style: TextStyle(color: const Color(0xFF2563EB), fontSize: 13)),
              underline: const SizedBox(),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        elevation: 4,
        color: ranked ? const Color(0xFFF0FFF4) : const Color(0xFFDCFCE7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ranked ? const Color(0xFF10B981) : const Color(0xFF22C55E),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    ranked ? Icons.calculate : Icons.info_outline,
                    color: const Color(0xFF059669),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ranked ? 'Rumus SAW (Simple Additive Weighting)' : 'Rumus Normalisasi Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!ranked) ...[
                _buildFormulaSection(
                  'Kriteria Benefit (Melodi, Lirik, Produksi Lagu):',
                  'r = x / max(x)',
                  'Nilai dibagi nilai maksimum',
                  const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                _buildFormulaSection(
                  'Kriteria Cost (Harga):',
                  'r = min(x) / x',
                  'Nilai minimum dibagi nilai',
                  const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pie_chart, color: Color(0xFF047857), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Bobot Kriteria:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildWeightChip('Melodi', '35%', Colors.green),
                          _buildWeightChip('Lirik', '30%', Colors.teal),
                          _buildWeightChip('Produksi', '25%', Colors.cyan),
                          _buildWeightChip('Harga', '10%', Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildFormulaSection(
                  'Rumus SAW:',
                  'Skor = Σ(Wi × Ri)',
                  'Jumlah dari (Bobot × Nilai Normalisasi)',
                  const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedCriterion == 'all' || selectedCriterion == null
                        ? 'Skor = (Melodi × 0.35) + (Lirik × 0.30) + (Produksi × 0.25) + (Harga × 0.10)'
                        : 'Skor = ${_getCriterionLabel()} × ${_getSelectedWeight()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: RankingChartSaw(songs: songs),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    final displaySongs = songs.length > 100 ? songs.sublist(0, 100) : songs;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: displaySongs.length,
      itemBuilder: (context, i) {
        final s = displaySongs[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: ranked ? const Color(0xFFFEF3C7) : const Color(0xFFBFDBFE),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ranked ? const Color(0xFFD97706) : const Color(0xFF2563EB)),
              ),
            ),
            title: Text(
              s.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              s.artist,
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: ranked
                ? const Icon(Icons.star, color: Color(0xFFFBBF24))
                : const Icon(Icons.music_note, color: Color(0xFF3B82F6)),
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nilai Asli:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Melodi: ${s.melody}'),
                    Text('Lirik: ${s.lyric}'),
                    Text('Produksi: ${s.production}'),
                    Text('Harga: ${currency.format(s.price)}'),
                    const Divider(),
                    const Text('Nilai Normalisasi:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Melodi: ${fmt(s.normalized['melody'] ?? 0)}'),
                    Text('Lirik: ${fmt(s.normalized['lyric'] ?? 0)}'),
                    Text('Produksi: ${fmt(s.normalized['production'] ?? 0)}'),
                    Text('Harga: ${fmt(s.normalized['price'] ?? 0)}'),
                    if (ranked) ...[
                      const Divider(),
                      Text('Skor Akhir SAW: ${fmt(s.score, 4)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF059669))),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormulaSection(
      String title, String formula, String description, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Text(
            formula,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: color.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChip(String label, String weight, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color[400]!, width: 1),
      ),
      child: Text(
        '$label: $weight',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color[900],
        ),
      ),
    );
  }

  String _getSelectedWeight() {
    if (selectedCriterion == null) return '1.0';
    final weights = {
      'melody': '0.35',
      'lyric': '0.30',
      'production': '0.25',
      'price': '0.10',
    };
    return weights[selectedCriterion] ?? '1.0';
  }
}

