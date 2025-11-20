import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../models/journal_model.dart';
import '../utils/constants.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _filter = "7 Hari"; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalProvider>(context, listen: false).fetchJournals();
    });
  }

  double _getMoodScore(String moodName) {
    final m = moodName.toLowerCase();
    if (m.contains('senang') || m.contains('semangat') || m.contains('excited')) return 5;
    if (m.contains('biasa') || m.contains('neutral')) return 3;
    if (m.contains('sedih') || m.contains('marah') || m.contains('cemas')) return 1;
    return 3; 
  }

  String _getMoodLabel(double score) {
    if (score >= 4.5) return "Senang 😄";
    if (score >= 2.5) return "Biasa 😐";
    return "Sedih 😔";
  }

  List<FlSpot> _generateSpots(List<Journal> journals) {
    List<FlSpot> spots = [];
    final now = DateTime.now();
    final daysCount = _filter == "7 Hari" ? 7 : 30;

    for (int i = daysCount - 1; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(targetDate);

      final dailyJournals = journals.where((j) => j.date == dateString).toList();

      double score = 0;
      if (dailyJournals.isNotEmpty) {
        double totalScore = 0;
        for (var j in dailyJournals) {
          totalScore += _getMoodScore(j.mood.name);
        }
        score = totalScore / dailyJournals.length;
      }
      spots.add(FlSpot((daysCount - 1 - i).toDouble(), score));
    }
    return spots;
  }

  // --- INTERAKSI BARU: POPUP RINCIAN MOOD ---
  void _showMoodBreakdown(BuildContext context, List<Journal> journals) {
    if (journals.isEmpty) return;
    
    // Hitung frekuensi
    var map = <String, int>{};
    for (var j in journals) {
      map[j.mood.name] = (map[j.mood.name] ?? 0) + 1;
    }
    // Urutkan dari terbanyak
    var sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    int total = journals.length;
    
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Komposisi Perasaan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text("Berdasarkan semua jurnalmu.", style: GoogleFonts.plusJakartaSans(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 24),
            
            // List Bar Chart Sederhana
            ...sorted.map((entry) {
              double percentage = entry.value / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(entry.key, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(height: 10, decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(5))),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(height: 10, decoration: BoxDecoration(color: _getMoodColor(entry.key), borderRadius: BorderRadius.circular(5))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text("${(percentage * 100).toStringAsFixed(0)}%", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String moodName) {
    // Helper warna simpel buat bar chart breakdown
    final m = moodName.toLowerCase();
    if (m.contains('senang') || m.contains('semangat')) return Colors.orange;
    if (m.contains('sedih') || m.contains('marah')) return Colors.blue;
    return Colors.grey;
  }

  // --- INTERAKSI BARU: POPUP DETAIL JURNAL ---
  void _showJournalStats(BuildContext context, List<Journal> journals) {
    if (journals.isEmpty) return;
    final theme = Theme.of(context);
    final firstDate = DateFormat.yMMMMd().format(DateTime.parse(journals.last.date)); // Asumsi sort desc
    final lastDate = DateFormat.yMMMMd().format(DateTime.parse(journals.first.date));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        title: Text("Statistik Penulisan", style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow("Total Tulisan", "${journals.length} Cerita", theme),
            const SizedBox(height: 12),
            _buildStatRow("Pertama Kali", firstDate, theme),
            const SizedBox(height: 12),
            _buildStatRow("Terakhir Kali", lastDate, theme),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final gridColor = isDark ? Colors.white10 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Wawasan Diri", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          final spots = _generateSpots(provider.journals);
          final daysCount = _filter == "7 Hari" ? 7 : 30;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FILTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip("7 Hari"),
                    const SizedBox(width: 12),
                    _buildFilterChip("30 Hari"),
                  ],
                ),
                const SizedBox(height: 32),

                // CHART
                Container(
                  height: 350, 
                  padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10, left: 10),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                    boxShadow: [
                      if (!isDark) BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 5))
                    ]
                  ),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: AppColors.primary, 
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final date = DateTime.now().subtract(Duration(days: daysCount - 1 - barSpot.x.toInt()));
                              final dateStr = DateFormat('d MMM').format(date);
                              final moodStr = _getMoodLabel(barSpot.y);
                              return LineTooltipItem(
                                '$dateStr\n',
                                const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                                children: [TextSpan(text: moodStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false, 
                        horizontalInterval: 1, 
                        getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1, dashArray: [5, 5]),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _filter == "7 Hari" ? 1 : 5, 
                            getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= daysCount) return const SizedBox();
                                if (index == 0 || index == daysCount ~/ 2 || index == daysCount - 1) {
                                  final date = DateTime.now().subtract(Duration(days: daysCount - 1 - index));
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(DateFormat('d MMM').format(date), style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 10)),
                                  );
                                }
                                return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30, 
                            getTitlesWidget: (value, meta) {
                              if (value == 1) return const Icon(Icons.cloud, color: Colors.blue, size: 18); 
                              if (value == 3) return Icon(Icons.sentiment_neutral, color: Colors.grey.shade400, size: 18); 
                              if (value == 5) return const Icon(Icons.wb_sunny, color: Colors.orange, size: 18); 
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0, maxX: (daysCount - 1).toDouble(), minY: 0, maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35, 
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true, 
                            getDotPainter: (spot, percent, barData, index) {
                              if (spot.y == 0) return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                              return FlDotCirclePainter(radius: 4, color: theme.cardTheme.color!, strokeWidth: 2, strokeColor: AppColors.primary);
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // SUMMARY CARDS (DENGAN INTERAKSI KLIK)
                Text("Ringkasan", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Total Jurnal", 
                        "${provider.journals.length}", 
                        Icons.book, 
                        Colors.purple, 
                        theme,
                        onTap: () => _showJournalStats(context, provider.journals) // KLIK TOTAL JURNAL
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        "Mood Dominan", 
                        _calculateDominantMood(provider.journals), 
                        Icons.pie_chart_rounded, 
                        Colors.orange, 
                        theme,
                        onTap: () => _showMoodBreakdown(context, provider.journals) // KLIK MOOD DOMINAN
                      )
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _filter = label),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold),
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.transparent)),
    );
  }

  // Update Widget ini biar bisa diklik (InkWell)
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, ThemeData theme, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap, // Efek Klik
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
          ],
        ),
      ),
    );
  }

  String _calculateDominantMood(List<Journal> journals) {
    if (journals.isEmpty) return "-";
    var map = <String, int>{};
    for (var j in journals) {
      map[j.mood.name] = (map[j.mood.name] ?? 0) + 1;
    }
    var sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}