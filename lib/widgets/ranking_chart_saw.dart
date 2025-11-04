import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

class RankingChartSaw extends StatelessWidget {
  final List<Song> songs;

  const RankingChartSaw({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final topSongs = songs.take(100).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart, color: Color(0xFF2563EB), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Grafik Skor SAW (Top 100 Lagu)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.white.withOpacity(0.8)),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= topSongs.length) return const SizedBox();
                      return Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    topSongs.length,
                    (i) => FlSpot(i.toDouble(), topSongs[i].score),
                  ),
                  isCurved: true,
                  color: const Color(0xFF2563EB),
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF2563EB).withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

