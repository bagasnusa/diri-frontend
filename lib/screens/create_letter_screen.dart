import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/letter_provider.dart';
import '../utils/constants.dart';

class CreateLetterScreen extends StatefulWidget {
  const CreateLetterScreen({super.key});

  @override
  State<CreateLetterScreen> createState() => _CreateLetterScreenState();
}

class _CreateLetterScreenState extends State<CreateLetterScreen> {
  final _messageController = TextEditingController();
  DateTime _openDate = DateTime.now().add(const Duration(days: 7)); 
  bool _isSending = false;

  void _submit() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Surat tidak boleh kosong.")));
      return;
    }

    setState(() => _isSending = true);

    final success = await Provider.of<LetterProvider>(context, listen: false)
        .sendLetter(_messageController.text, _openDate);

    setState(() => _isSending = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Surat dikirim ke masa depan!")));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim surat.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- VAR DINAMIS ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardTheme.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Tulis Surat", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        foregroundColor: textColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Info Header
            Text(
              "Untuk diriku di masa depan...",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, 
                color: AppColors.primary, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 24),

            // 2. Input Teks
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor, // Dinamis
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.6, color: textColor),
                  decoration: InputDecoration(
                    hintText: "Hai, apa kabar? Semoga saat kamu baca ini, kamu sudah...",
                    hintStyle: TextStyle(color: subTextColor?.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Pemilih Tanggal
            Text("Kapan surat ini boleh dibuka?", style: GoogleFonts.plusJakartaSans(color: subTextColor)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _openDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)), 
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  
                  // TEMA DATEPICKER DINAMIS
                  builder: (context, child) => Theme(
                    data: theme.copyWith(
                      colorScheme: isDark 
                        ? const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface)
                        : const ColorScheme.light(primary: AppColors.primary, surface: Colors.white),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _openDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor, // Dinamis
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMMMMd().format(_openDate),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSending 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Kunci & Kirim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}