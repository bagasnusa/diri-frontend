import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Paket Animasi
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart'; 
import 'mood_selector_screen.dart';
import 'journal_detail_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _todaysQuote; 

  final List<String> _quotes = [
    "Validasi terbaik datang dari dirimu sendiri.",
    "Tidak apa-apa untuk tidak merasa baik-baik saja.",
    "Hari ini adalah lembaran baru. Tulislah dengan jujur.",
    "Perasaanmu valid, serumit apapun itu.",
    "Ambil napas dalam-dalam. Kamu aman disini.",
    "Satu langkah kecil tetaplah sebuah langkah.",
    "Jadilah lembut pada hatimu sendiri hari ini.",
    "Badai pasti berlalu, tapi kamu akan tetap tumbuh.",
  ];

  @override
  void initState() {
    super.initState();
    _todaysQuote = _quotes[Random().nextInt(_quotes.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalProvider>(context, listen: false).fetchJournals();
    });
  }

  void _onSearch(String value) {
    Provider.of<JournalProvider>(context, listen: false).fetchJournals(keyword: value);
  }

  Color _parseColor(String hexCode) {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy').format(date); 
    } catch (e) {
      return dateString;
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    // VAR DINAMIS (Tema)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          return AnimationLimiter( // Pengontrol Animasi List
            child: CustomScrollView(
              slivers: [
                
                // --- 1. STICKY HEADER (LOGO + SEARCH) ---
                SliverAppBar(
                  expandedHeight: 240.0, 
                  floating: false,
                  pinned: true, // BIKIN NEMPEL SAAT SCROLL
                  backgroundColor: theme.cardTheme.color,
                  elevation: 0,
                  scrolledUnderElevation: 0, 
                  
                  // Bentuk Lengkung Bawah
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  
                  // LOGO & JUDUL
                  title: Row(
                    children: [
                      const AppLogo(size: 32, style: LogoStyle.soul, withText: false),
                      const SizedBox(width: 12),
                      Text(
                        'DIRI',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, 
                          letterSpacing: 3, 
                          color: AppColors.primary, 
                          fontSize: 20
                        ),
                      ),
                    ],
                  ),
                  
                  // TOMBOL LOGOUT
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CircleAvatar(
                        backgroundColor: theme.scaffoldBackgroundColor,
                        radius: 18,
                        child: IconButton(
                          icon: Icon(Icons.logout_rounded, size: 18, color: textTheme.bodyMedium?.color),
                          onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],

                  // BAGIAN SAPAAN (HILANG SAAT SCROLL)
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60), 
                          Text(
                            "${_getGreeting()},", 
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, color: textTheme.bodyMedium?.color)
                          ),
                          Text(
                            "Apa ceritamu?", 
                            style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                          ),
                          const SizedBox(height: 60), // Spacer buat search bar
                        ],
                      ),
                    ),
                  ),

                  // SEARCH BAR (MENEMPEL/STICKY)
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80), 
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      alignment: Alignment.bottomCenter,
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearch,
                        textInputAction: TextInputAction.search,
                        style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          hintText: "Cari kenangan...",
                          hintStyle: TextStyle(color: textTheme.bodyMedium?.color?.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.search_rounded, color: textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor, // Warna beda dikit dari header
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: textTheme.bodyMedium?.color),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- 2. DAILY INSIGHT (KARTU GRADIENT) ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withOpacity(0.9), const Color(0xFF26A69A)], 
                          begin: Alignment.topLeft, 
                          end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8), 
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), 
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text("INSIGHT HARI INI", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white70)), 
                                const SizedBox(height: 4), 
                                Text('"$_todaysQuote"', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, fontStyle: FontStyle.italic))
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- 3. LIST JURNAL ---
                if (provider.isLoading)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                else if (provider.journals.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.3, 
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0]), 
                              child: const AppLogo(size: 100, style: LogoStyle.soul, withText: false)
                            )
                          ),
                          const SizedBox(height: 20),
                          Text("Hening sekali disini.", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          Text("Mulai tulis ceritamu hari ini.", style: GoogleFonts.plusJakartaSans(color: textTheme.bodyMedium?.color?.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final journal = provider.journals[index];
                        final moodColor = _parseColor(journal.mood.colorCode);
                        final hasImage = journal.imageUrl != null && journal.imageUrl!.isNotEmpty;
                        final hasVoice = journal.voiceUrl != null && journal.voiceUrl!.isNotEmpty;
                        final hasMusic = journal.musicLink != null && journal.musicLink!.isNotEmpty;

                        // ANIMASI ITEM MUNCUL (Slide & Fade)
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                                  boxShadow: [if (!isDark) BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => JournalDetailScreen(journal: journal)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // TANGGAL
                                        Align(
                                          alignment: Alignment.centerRight, 
                                          child: Text(_formatDate(journal.date), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: textTheme.bodyMedium?.color?.withOpacity(0.5)))
                                        ),
                                        const SizedBox(height: 8),

                                        // KONTEN + LINE MOOD
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(width: 4, height: 60, decoration: BoxDecoration(color: moodColor, borderRadius: BorderRadius.circular(2))),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    journal.content, 
                                                    maxLines: 3, 
                                                    overflow: TextOverflow.ellipsis, 
                                                    style: GoogleFonts.plusJakartaSans(fontSize: 15, height: 1.5, color: colorScheme.onSurface)
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // BADGES
                                                  Row(
                                                    children: [
                                                      _buildBadge(text: journal.mood.name, color: moodColor, isDark: isDark, theme: theme),
                                                      if (hasVoice) ...[const SizedBox(width: 8), _buildIconBadge(Icons.mic_rounded, Colors.redAccent, isDark, theme)],
                                                      if (hasMusic) ...[const SizedBox(width: 8), _buildIconBadge(Icons.music_note_rounded, Colors.blueAccent, isDark, theme)],
                                                      if (hasImage) ...[const SizedBox(width: 8), _buildIconBadge(Icons.image_rounded, Colors.purpleAccent, isDark, theme)],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            // HERO IMAGE ANIMATION
                                            if (hasImage) ...[
                                              const SizedBox(width: 12),
                                              Hero(
                                                tag: 'journal-img-${journal.id}',
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    journal.imageUrl!,
                                                    width: 70, height: 70, fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => Container(width: 70, height: 70, color: theme.scaffoldBackgroundColor),
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: provider.journals.length,
                    ),
                  ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodSelectorScreen())),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 4,
        label: const Text("Tulis Cerita", style: TextStyle(fontWeight: FontWeight.bold)), icon: const Icon(Icons.edit_rounded),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildBadge({required String text, required Color color, required bool isDark, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3), width: 1)),
      child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3), width: 1)),
      child: Icon(icon, size: 14, color: color),
    );
  }
}