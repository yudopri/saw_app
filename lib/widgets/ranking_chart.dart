import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

class RankingChart extends StatelessWidget {
  final List<Song> songs;
  const RankingChart({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final topSongs = songs.take(10).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tren Skor SAW (Top 10 Lagu)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= topSongs.length) {
                          return const SizedBox();
                        }
                        return Transform.rotate(
                          angle: -0.6,
                          child: Text(
                            topSongs[i].title,
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 9),
                      ),
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
                    gradient: const LinearGradient(
                      colors: [Colors.indigo, Colors.blueAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withOpacity(0.3),
                          Colors.blueAccent.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
