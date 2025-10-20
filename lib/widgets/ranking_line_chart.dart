import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

class RankingLineChart extends StatelessWidget {
  final List<Song> songs;

  const RankingLineChart({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final topSongs = songs.take(20).toList();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= topSongs.length) return const SizedBox();
                  return Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      topSongs[index].title.split(' ').first,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                topSongs.length,
                (i) => FlSpot(i.toDouble(), topSongs[i].score),
              ),
              isCurved: true,
              color: Colors.indigo,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.indigo.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}
