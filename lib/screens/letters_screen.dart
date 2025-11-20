import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/letter_provider.dart';
import '../utils/constants.dart';
import 'create_letter_screen.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LetterProvider>(context, listen: false).fetchLetters();
    });
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showLetterContent(String content, String date) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text("Pesan Masa Lalu", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.6, color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Ditulis pada: $date",
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: theme.textTheme.bodyMedium?.color, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- VAR DINAMIS ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Kapsul Waktu", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        foregroundColor: textColor,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Consumer<LetterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card (Gradient selalu sama karena Brand Color)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateLetterScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF4DB6AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_note_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kirim Pesan Baru",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              "Tulis harapanmu untuk masa depan.",
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              Text(
                "Kotak Surat",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: subTextColor),
              ),
              const SizedBox(height: 16),

              if (provider.letters.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Center(child: Text("Belum ada surat yang dikirim.", style: TextStyle(color: subTextColor?.withOpacity(0.5)))),
                )
              else
                ...provider.letters.map((letter) {
                  final bool isLocked = letter['is_locked'];
                  final String openDate = _formatDate(letter['open_date']);
                  final String createDate = _formatDate(letter['created_at']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      // Background Card Dinamis
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () {
                        if (isLocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Surat ini baru bisa dibuka tanggal $openDate"))
                          );
                        } else {
                          _showLetterContent(letter['message'], createDate);
                        }
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isLocked ? theme.scaffoldBackgroundColor : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_outline_rounded : Icons.mark_email_read_rounded,
                          color: isLocked ? subTextColor : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        isLocked ? "Terkunci oleh Waktu" : "Pesan Terbuka",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: isLocked ? subTextColor : textColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            isLocked 
                              ? "Terbuka otomatis pada $openDate" 
                              : "Klik untuk membaca pesan masa lalu.",
                            style: TextStyle(fontSize: 12, color: subTextColor?.withOpacity(0.7)),
                          ),
                        ],
                      ),
                      trailing: isLocked 
                        ? Icon(Icons.hourglass_empty_rounded, size: 16, color: subTextColor)
                        : const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}