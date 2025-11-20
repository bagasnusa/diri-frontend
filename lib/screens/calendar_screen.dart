import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart'; 
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../utils/constants.dart';
import 'journal_detail_screen.dart'; 

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<JournalProvider>(context, listen: false);
      provider.fetchCalendarData();
      provider.fetchJournals(); 
    });
  }

  Color _parseColor(String hexCode) {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Color? _getMoodColorForDay(DateTime day, List<Map<String, dynamic>> data) {
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    final entries = data.where((element) => element['date'] == dateString).toList();
    if (entries.isEmpty) return null;
    final latest = entries.last;
    return _parseColor(latest['mood_color']);
  }

  @override
  Widget build(BuildContext context) {
    // --- VAR DINAMIS ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jejak Perasaan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        foregroundColor: textColor, // Dinamis
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          final selectedJournals = _selectedDay != null 
              ? provider.getJournalsByDate(_selectedDay!) 
              : [];

          return Column(
            children: [
              // 1. KALENDER
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Background ikut tema (Putih/Abu)
                  color: theme.cardTheme.color, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: GoogleFonts.plusJakartaSans(
                      color: textColor, fontWeight: FontWeight.bold, fontSize: 16
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: textColor), // Angka tanggal dinamis
                    weekendTextStyle: TextStyle(color: subTextColor), // Weekend dinamis
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final color = _getMoodColorForDay(date, provider.calendarData);
                      if (color == null) return null;

                      return Positioned(
                        bottom: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
                            ]
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),
              
              // 2. LIST JURNAL DI TANGGAL TERSEBUT
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color, // Background List Dinamis
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      if (!isDark) // Bayangan halus kalau light mode
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -5))
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        _selectedDay != null 
                          ? "Cerita pada ${DateFormat.yMMMMd().format(_selectedDay!)}" 
                          : "Pilih Tanggal",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (selectedJournals.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              "Tidak ada catatan hari ini.",
                              style: GoogleFonts.plusJakartaSans(color: subTextColor?.withOpacity(0.5)),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: selectedJournals.length,
                            itemBuilder: (context, index) {
                              final journal = selectedJournals[index];
                              final moodColor = _parseColor(journal.mood.colorCode);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  // Warna item list beda dikit dari background container
                                  color: theme.scaffoldBackgroundColor, 
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => JournalDetailScreen(journal: journal)));
                                  },
                                  leading: Container(
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(color: moodColor, shape: BoxShape.circle),
                                  ),
                                  title: Text(
                                    journal.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(color: textColor, fontSize: 14),
                                  ),
                                  trailing: Icon(Icons.chevron_right, color: subTextColor, size: 16),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}