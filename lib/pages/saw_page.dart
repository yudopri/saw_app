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
    {'key': 'popularity', 'label': 'Tingkat Popularitas'},
    {'key': 'danceability', 'label': 'Kesesuaian untuk Menari'},
    {'key': 'energy', 'label': 'Tingkat Energi'},
    {'key': 'acousticness', 'label': 'Tingkat Akustik'},
    {'key': 'duration', 'label': 'Lama Durasi'},
    {'key': 'valence', 'label': 'Tingkat Kegembiraan'},
    {'key': 'all', 'label': 'Semua Kriteria Digabung'},
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
                  'Kriteria Manfaat (Popularitas, Kesesuaian Menari, Energi, Kegembiraan):',
                  'r = x / max(x)',
                  'Nilai dibagi dengan nilai tertinggi',
                  const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                _buildFormulaSection(
                  'Kriteria Biaya (Akustik, Durasi):',
                  'r = min(x) / x',
                  'Nilai terendah dibagi dengan nilai saat ini',
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
                            'Bobot Setiap Kriteria:',
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
                          _buildWeightChip('Popularitas', '25%', Colors.green),
                          _buildWeightChip('Kesesuaian Menari', '20%', Colors.teal),
                          _buildWeightChip('Energi', '20%', Colors.cyan),
                          _buildWeightChip('Akustik', '10%', Colors.amber),
                          _buildWeightChip('Durasi', '10%', Colors.orange),
                          _buildWeightChip('Kegembiraan', '15%', Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildFormulaSection(
                  'Rumus Metode SAW:',
                  'Skor = Σ(Wi × Ri)',
                  'Total dari (Bobot dikali Nilai Ternormalisasi)',
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
                        ? 'Skor = (Popularitas × 0.25) + (Kesesuaian Menari × 0.20) + (Energi × 0.20) + (Akustik × 0.10) + (Durasi × 0.10) + (Kegembiraan × 0.15)'
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
                      const Text('✨ Perhitungan Skor Akhir SAW:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
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
                              'Rumus: Skor = Σ(Bobot × Nilai Ternormalisasi)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Skor = (${fmt(s.normalized['popularity'] ?? 0, 4)} × 0.25) +',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '       (${fmt(s.normalized['danceability'] ?? 0, 4)} × 0.20) +',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '       (${fmt(s.normalized['energy'] ?? 0, 4)} × 0.20) +',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '       (${fmt(s.normalized['acousticness'] ?? 0, 4)} × 0.10) +',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '       (${fmt(s.normalized['duration'] ?? 0, 4)} × 0.10) +',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '       (${fmt(s.normalized['valence'] ?? 0, 4)} × 0.15)',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Divider(height: 16),
                            Text(
                              'Skor = ${fmt((s.normalized['popularity'] ?? 0) * 0.25, 4)} + ${fmt((s.normalized['danceability'] ?? 0) * 0.20, 4)} + ${fmt((s.normalized['energy'] ?? 0) * 0.20, 4)} + ${fmt((s.normalized['acousticness'] ?? 0) * 0.10, 4)} + ${fmt((s.normalized['duration'] ?? 0) * 0.10, 4)} + ${fmt((s.normalized['valence'] ?? 0) * 0.15, 4)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Skor Akhir SAW:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${fmt(s.score, 4)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF059669),
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
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
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
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedWeight() {
    final Map<String, String> weights = {
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

