import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/song.dart';
import '../services/csv_loader.dart';
import '../services/wp_service.dart';
import '../widgets/ranking_line_chart.dart';

class WpPage extends StatefulWidget {
  const WpPage({super.key});

  @override
  State<WpPage> createState() => _WpPageState();
}

class _WpPageState extends State<WpPage> {
  final CsvLoader csvLoader = CsvLoader();
  final WpService wpService = WpService();

  List<Song> songs = [];
  bool loading = true;
  bool ranked = false;
  String? selectedCriterion;

  final currency =
  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final List<Map<String, String>> criteria = [
    {'key': 'popularity', 'label': 'Popularitas'},
    {'key': 'danceability', 'label': 'Danceability'},
    {'key': 'energy', 'label': 'Energy'},
    {'key': 'acousticness', 'label': 'Acousticness'},
    {'key': 'duration', 'label': 'Durasi'},
    {'key': 'valence', 'label': 'Valence'},
    {'key': 'duration', 'label': 'Durasi'},
    {'key': 'valence', 'label': 'Valence'},
    {'key': 'duration', 'label': 'Durasi'},
    {'key': 'valence', 'label': 'Kebahagiaan'},
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

  void _calculateWp() {
    setState(() {
      ranked = true;
    });
    wpService.calculate(
      songs,
      selectedCriterion: selectedCriterion == 'all' ? null : selectedCriterion,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perangkingan WP berdasarkan ${_getCriterionLabel()} berhasil!',
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
          ranked ? 'Hasil Perangkingan Weighted Product' : 'Data Lagu Mentah (WP)',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF6B46C1), // Deep purple untuk WP
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
        selectedCriterion == null ? null : (ranked ? _loadData : _calculateWp),
        backgroundColor:
        selectedCriterion == null ? Colors.grey : (ranked ? const Color(0xFFE91E63) : const Color(0xFF6B46C1)),
        foregroundColor: Colors.white,
        icon: Icon(ranked ? Icons.refresh : Icons.auto_graph),
        label: Text(
          ranked ? 'Kembali ke Data Mentah' : 'Hitung WP',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B46C1), const Color(0xFF8B5CF6)],
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
                  style: TextStyle(color: const Color(0xFF6B46C1), fontSize: 13)),
              underline: const SizedBox(),
              style: const TextStyle(
                color: Color(0xFF6B46C1),
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
        color: ranked ? const Color(0xFFF0FFF4) : const Color(0xFFFAF5FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ranked ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
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
                    color: ranked ? const Color(0xFF059669) : const Color(0xFF7C3AED),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ranked ? 'Rumus Weighted Product' : 'Rumus Normalisasi Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ranked ? const Color(0xFF047857) : const Color(0xFF6B21A8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!ranked) ...[
                _buildFormulaSection(
                  'Kriteria Manfaat (Popularitas, Kesesuaian Menari, Energi, Kegembiraan):',
                  'r = x / max(x)',
                  'Nilai dibagi dengan nilai tertinggi',
                  const Color(0xFF7C3AED),
                ),
                const SizedBox(height: 8),
                _buildFormulaSection(
                  'Kriteria Biaya (Akustik, Durasi):',
                  'r = min(x) / x',
                  'Nilai terendah dibagi dengan nilai saat ini',
                  const Color(0xFF7C3AED),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pie_chart, color: Color(0xFF6B21A8), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Bobot Setiap Kriteria:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B21A8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildWeightChip('Popularitas', '25%', Colors.deepPurple),
                          _buildWeightChip('Kesesuaian Menari', '20%', Colors.purple),
                          _buildWeightChip('Energi', '20%', Colors.pink),
                          _buildWeightChip('Akustik', '10%', Colors.amber),
                          _buildWeightChip('Durasi', '10%', Colors.orange),
                          _buildWeightChip('Kegembiraan', '15%', Colors.indigo),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildFormulaSection(
                  'Langkah 1: Normalisasi Bobot',
                  "W' = W / Total W",
                  'Bobot dibagi dengan total semua bobot (hasilnya = 1.0)',
                  Colors.green[700]!,
                ),
                const SizedBox(height: 8),
                _buildFormulaSectionMultiLine(
                  'Langkah 2: Hitung Vektor S (Nilai Preferensi)',
                  selectedCriterion == 'all' || selectedCriterion == null
                      ? [
                    "S = (Popularitas ^ 0.25) ×",
                    "    (Kesesuaian Menari ^ 0.20) ×",
                    "    (Energi ^ 0.20) ×",
                    "    (Akustik ^ 0.10) ×",
                    "    (Durasi ^ 0.10) ×",
                    "    (Kegembiraan ^ 0.15)"
                  ]
                      : ["S = (${_getCriterionLabel()} ^ ${_getSelectedWeight()})"],
                  selectedCriterion == 'all' || selectedCriterion == null
                      ? 'Hasil perkalian pangkat dari semua kriteria'
                      : 'Hanya menggunakan kriteria ${_getCriterionLabel()}',
                  Colors.green[700]!,
                ),
                const SizedBox(height: 8),
                _buildFormulaSection(
                  'Langkah 3: Hitung Vektor V (Preferensi Relatif)',
                  'V = S / Total S',
                  'Total semua V = 1.0, nilai V tertinggi = lagu terbaik',
                  Colors.green[700]!,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: Colors.green[900]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Peringkat ditentukan dari nilai V yang paling tinggi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                    ],
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
          child: RankingLineChart(songs: songs),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: songs.length,
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
              backgroundColor: ranked ? const Color(0xFFFEF3C7) : const Color(0xFFDDD6FE),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ranked ? const Color(0xFFD97706) : const Color(0xFF6B46C1)),
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
                : const Icon(Icons.music_note, color: Color(0xFF8B5CF6)),
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 Nilai Asli:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Tingkat Popularitas: ${s.popularity}'),
                    Text('Kesesuaian untuk Menari: ${s.danceability}'),
                    Text('Tingkat Energi: ${s.energy}'),
                    Text('Tingkat Akustik: ${s.acousticness}'),
                    Text('Lama Durasi: ${(s.duration / 1000).toStringAsFixed(2)} detik'),
                    Text('Tingkat Kegembiraan: ${s.valence}'),
                    const Divider(),
                    const Text('🧮 Nilai Ternormalisasi (Cara Hitung):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    if (ranked) ...[
                      _buildNormalizationDetail(
                        'Popularitas',
                        s.popularity,
                        songs.map((x) => x.popularity).reduce((a, b) => a > b ? a : b),
                        s.normalized['popularity'] ?? 0,
                        true,
                      ),
                      _buildNormalizationDetail(
                        'Kesesuaian Menari',
                        s.danceability,
                        songs.map((x) => x.danceability).reduce((a, b) => a > b ? a : b),
                        s.normalized['danceability'] ?? 0,
                        true,
                      ),
                      _buildNormalizationDetail(
                        'Energi',
                        s.energy,
                        songs.map((x) => x.energy).reduce((a, b) => a > b ? a : b),
                        s.normalized['energy'] ?? 0,
                        true,
                      ),
                      _buildNormalizationDetail(
                        'Akustik',
                        s.acousticness,
                        songs.map((x) => x.acousticness).reduce((a, b) => a < b ? a : b),
                        s.normalized['acousticness'] ?? 0,
                        false,
                      ),
                      _buildNormalizationDetail(
                        'Durasi',
                        s.duration,
                        songs.map((x) => x.duration).reduce((a, b) => a < b ? a : b),
                        s.normalized['duration'] ?? 0,
                        false,
                      ),
                      _buildNormalizationDetail(
                        'Kegembiraan',
                        s.valence,
                        songs.map((x) => x.valence).reduce((a, b) => a > b ? a : b),
                        s.normalized['valence'] ?? 0,
                        true,
                      ),
                      const Divider(),
                      const Text('✨ Perhitungan Metode WP:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),

                      // Perhitungan Vektor S
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple.shade300, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Langkah 1: Hitung Vektor S',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF6B21A8),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Rumus: S = Π(Nilai Ternormalisasi ^ Bobot)',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'S = (${fmt(s.normalized['popularity'] ?? 0, 4)} ^ 0.25) ×',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              '    (${fmt(s.normalized['danceability'] ?? 0, 4)} ^ 0.20) ×',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              '    (${fmt(s.normalized['energy'] ?? 0, 4)} ^ 0.20) ×',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              '    (${fmt(s.normalized['acousticness'] ?? 0, 4)} ^ 0.10) ×',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              '    (${fmt(s.normalized['duration'] ?? 0, 4)} ^ 0.10) ×',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              '    (${fmt(s.normalized['valence'] ?? 0, 4)} ^ 0.15)',
                              style: const TextStyle(fontSize: 11),
                            ),
                            const Divider(height: 12),
                            Text(
                              'S = ${fmt(pow(s.normalized['popularity'] ?? 0, 0.25).toDouble(), 4)} × ${fmt(pow(s.normalized['danceability'] ?? 0, 0.20).toDouble(), 4)} × ${fmt(pow(s.normalized['energy'] ?? 0, 0.20).toDouble(), 4)} × ${fmt(pow(s.normalized['acousticness'] ?? 0, 0.10).toDouble(), 4)} × ${fmt(pow(s.normalized['duration'] ?? 0, 0.10).toDouble(), 4)} × ${fmt(pow(s.normalized['valence'] ?? 0, 0.15).toDouble(), 4)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vektor S =',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    '${fmt(s.vectorS, 4)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Perhitungan Vektor V
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Langkah 2: Hitung Vektor V',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Rumus: V = S / ΣS (Total Semua S)',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total S = ${fmt(songs.fold(0.0, (sum, song) => sum + song.vectorS), 4)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'V = ${fmt(s.vectorS, 4)} / ${fmt(songs.fold(0.0, (sum, song) => sum + song.vectorS), 4)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vektor V (Skor Akhir) =',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    '${fmt(s.vectorV, 4)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text('Popularitas: ${fmt(s.normalized['popularity'] ?? 0)}'),
                      Text('Kesesuaian Menari: ${fmt(s.normalized['danceability'] ?? 0)}'),
                      Text('Energi: ${fmt(s.normalized['energy'] ?? 0)}'),
                      Text('Akustik: ${fmt(s.normalized['acousticness'] ?? 0)}'),
                      Text('Durasi: ${fmt(s.normalized['duration'] ?? 0)}'),
                      Text('Kegembiraan: ${fmt(s.normalized['valence'] ?? 0)}'),
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

  Widget _buildFormulaSectionMultiLine(
      String title, List<String> formulas, String description, Color color) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: formulas.map((formula) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              );
            }).toList(),
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

  Widget _buildNormalizationDetail(String label, double value, double compareValue, double result, bool isBenefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              isBenefit
                  ? '= $value / $compareValue (nilai ÷ nilai tertinggi)'
                  : '= $compareValue / $value (nilai terendah ÷ nilai)',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            Text(
              '= ${fmt(result, 4)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedWeight() {
    if (selectedCriterion == null) return '1.0';
    final weights = {
      'popularity': '0.25',
      'danceability': '0.20',
      'energy': '0.20',
      'acousticness': '0.10',
      'duration': '0.10',
      'valence': '0.15',
    };
    return weights[selectedCriterion] ?? '1.0';
  }
}