import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/journal_provider.dart';
import '../models/journal_model.dart';
import '../utils/constants.dart';
import 'journal_editor_screen.dart'; 

class MoodSelectorScreen extends StatefulWidget {
  const MoodSelectorScreen({super.key});

  @override
  State<MoodSelectorScreen> createState() => _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends State<MoodSelectorScreen> {
  List<Mood> _moods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  void _loadMoods() async {
    try {
      final service = Provider.of<JournalProvider>(context, listen: false).service; 
      final moods = await service.getMoods();
      setState(() {
        _moods = moods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Color _parseColor(String hexCode) {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  // LOGIKA ICON MOOD (Biar ga bunder doang)
  IconData _getMoodIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'happy': return Icons.sentiment_very_satisfied_rounded; // Senyum Lebar
      case 'sad': return Icons.water_drop_rounded; // Air mata / Hujan
      case 'angry': return Icons.flash_on_rounded; // Petir / Marah
      case 'anxious': return Icons.cyclone_rounded; // Pikiran ruwet / Spiral
      case 'neutral': return Icons.sentiment_neutral_rounded; // Datar
      case 'excited': return Icons.auto_awesome_rounded; // Bintang / Semangat
      default: return Icons.circle; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- VAR DINAMIS ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Fix Bocor
      appBar: AppBar(
        title: const Text("Check-in"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor, // Fix Bocor
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bagaimana perasaanmu\nsaat ini?",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textColor, // Fix Bocor
              ),
            ),
            const SizedBox(height: 32),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, // Sedikit lebih kotak biar icon muat
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    final color = _parseColor(mood.colorCode);
                    final iconData = _getMoodIcon(mood.iconName);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JournalEditorScreen(mood: mood),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          // Background ikut tema card (Putih/Abu)
                          color: theme.cardTheme.color, 
                          borderRadius: BorderRadius.circular(24),
                          // Border tipis warna mood biar manis
                          border: Border.all(color: color.withOpacity(0.3), width: 2),
                          boxShadow: [
                            if (!isDark) // Shadow halus cuma di light mode
                              BoxShadow(
                                color: color.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Lingkaran Background Icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2), // Warna mood transparan
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                iconData, 
                                color: color, // Icon warna mood solid
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mood.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor, // Text ikut tema
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}