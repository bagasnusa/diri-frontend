import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../models/journal_model.dart';
import '../providers/journal_provider.dart';
import '../utils/constants.dart';

class JournalEditorScreen extends StatefulWidget {
  final Mood mood; 
  final Journal? existingJournal; 

  const JournalEditorScreen({super.key, required this.mood, this.existingJournal});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  File? _selectedImage;
  String? _musicLink;
  
  // Audio vars
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInited = false;
  bool _isRecording = false;
  String? _recordedFilePath; 
  bool _hasVoiceNote = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initRecorder();

    if (widget.existingJournal != null) {
      _contentController = TextEditingController(text: widget.existingJournal!.content);
      _selectedDate = DateTime.parse(widget.existingJournal!.date);
      _musicLink = widget.existingJournal!.musicLink;
    } else {
      _contentController = TextEditingController();
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    // Minta izin saat layar dibuka biar siap
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return; // Izin ditolak
    }
    await _recorder!.openRecorder();
    setState(() {
      _isRecorderInited = true;
    });
  }

  @override
  void dispose() {
    if (_recorder != null) {
      _recorder!.closeRecorder();
      _recorder = null;
    }
    super.dispose();
  }

  Color _getMoodColor() {
    try {
      return Color(int.parse(widget.mood.colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  // --- LOGIKA REKAM YANG LEBIH STABIL ---
  Future<void> _toggleRecording() async {
    if (!_isRecorderInited) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mikrofon belum siap. Coba keluar masuk lagi.")));
      return;
    }

    if (_recorder!.isStopped) {
      // Mulai Rekam
      final dir = await getTemporaryDirectory();
      // Pakai format AAC (standar android/ios)
      final path = '${dir.path}/temp_audio.aac'; 
      
      await _recorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() => _isRecording = true);
    } else {
      // Stop Rekam
      final path = await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
        _hasVoiceNote = true;
      });
    }
  }

  void _deleteRecording() {
    setState(() {
      _recordedFilePath = null;
      _hasVoiceNote = false;
    });
  }

  void _addMusicLink() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        String tempLink = "";
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          title: Text("Link Lagu", style: TextStyle(color: theme.colorScheme.onSurface)),
          content: TextField(
            style: TextStyle(color: theme.colorScheme.onSurface),
            onChanged: (val) => tempLink = val,
            controller: TextEditingController(text: _musicLink),
            decoration: InputDecoration(
              hintText: "http://...",
              hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            TextButton(
              onPressed: () {
                setState(() => _musicLink = tempLink);
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _saveJournal() async {
    // Validasi minimal ada satu konten
    if (_contentController.text.trim().isEmpty && _selectedImage == null && !_hasVoiceNote) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi jurnal kosong.")));
      return;
    }

    setState(() => _isSaving = true);

    File? voiceFile;
    if (_recordedFilePath != null) {
      voiceFile = File(_recordedFilePath!);
    }

    try {
      bool success;
      // Logic Create/Update
      if (widget.existingJournal != null) {
        success = await Provider.of<JournalProvider>(context, listen: false).updateJournal(
          widget.existingJournal!.id,
          widget.mood.id, 
          _contentController.text, 
          _selectedDate,
          image: _selectedImage,
          musicLink: _musicLink,
          voice: voiceFile 
        );
      } else {
        success = await Provider.of<JournalProvider>(context, listen: false).addJournal(
          widget.mood.id, 
          _contentController.text, 
          _selectedDate,
          image: _selectedImage,
          musicLink: _musicLink,
          voice: voiceFile 
        );
      }

      if (success && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan.")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan ke server.")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _getMoodColor();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Color.alphaBlend(moodColor.withOpacity(0.05), theme.scaffoldBackgroundColor),
      resizeToAvoidBottomInset: true, // PENTING: Biar keyboard ga nutup tombol
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.existingJournal != null ? "Edit Cerita" : "Tulis Cerita", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveJournal,
              style: TextButton.styleFrom(
                backgroundColor: moodColor, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      
      body: Column(
        children: [
          // BAGIAN SCROLL (KONTEN)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: theme.copyWith(
                            colorScheme: isDark 
                              ? const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface)
                              : const ColorScheme.light(primary: AppColors.primary, surface: Colors.white),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: Row(
                      children: [
                        Text(DateFormat.yMMMMd().format(_selectedDate), style: GoogleFonts.plusJakartaSans(color: subTextColor, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_drop_down, color: subTextColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Mood
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: moodColor, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text("Aku merasa ${widget.mood.name}...", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Preview Image
                  if (_selectedImage != null)
                    _buildMediaPreview(
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      onDelete: () => setState(() => _selectedImage = null),
                    )
                  else if (widget.existingJournal?.imageUrl != null)
                     _buildMediaPreview(
                      child: Image.network(widget.existingJournal!.imageUrl!, fit: BoxFit.cover),
                      onDelete: null // Gambar lama ga bisa dihapus dulu biar simpel
                    ),

                  // 4. Preview Voice Note (INDIKATOR)
                  if (_hasVoiceNote || _isRecording)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isRecording ? AppColors.error.withOpacity(0.1) : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _isRecording ? AppColors.error : moodColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mic_rounded, color: _isRecording ? AppColors.error : AppColors.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _isRecording ? "Sedang Merekam..." : "Suara Siap Disimpan",
                              style: TextStyle(
                                color: _isRecording ? AppColors.error : textColor,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          if (!_isRecording)
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: subTextColor),
                              onPressed: _deleteRecording,
                            )
                        ],
                      ),
                    ),

                  // 5. Preview Music
                  if (_musicLink != null && _musicLink!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12), border: Border.all(color: moodColor.withOpacity(0.5))),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_musicLink!, style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis)),
                          IconButton(icon: Icon(Icons.close, color: subTextColor), onPressed: () => setState(() => _musicLink = null)),
                        ],
                      ),
                    ),

                  // 6. Text Field
                  TextField(
                    controller: _contentController,
                    maxLines: null, 
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, height: 1.6, color: textColor),
                    decoration: InputDecoration(
                      hintText: "Ceritakan semuanya...",
                      hintStyle: GoogleFonts.plusJakartaSans(color: subTextColor?.withOpacity(0.5)),
                      border: InputBorder.none, 
                    ),
                  ),
                  const SizedBox(height: 100), // Spacer biar ga ketutup toolbar
                ],
              ),
            ),
          ),

          // BAGIAN TETAP (TOOLBAR)
          Container(
            padding: const EdgeInsets.all(16), // Padding aman
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200)),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea( // PENTING: Biar ga kena tombol home iPhone/Android Gesture
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolbarButton(Icons.image_rounded, "Foto", _pickImage, active: _selectedImage != null),
                  _buildToolbarButton(Icons.music_note_rounded, "Musik", _addMusicLink, active: _musicLink != null),
                  
                  // Tombol Mic Special
                  InkWell(
                    onTap: _toggleRecording,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isRecording ? AppColors.error : (_hasVoiceNote ? AppColors.primary : theme.scaffoldBackgroundColor),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: (_isRecording || _hasVoiceNote) ? Colors.white : subTextColor,
                        size: 24,
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

  Widget _buildMediaPreview({required Widget child, VoidCallback? onDelete}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200, width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
        ),
        if (onDelete != null)
          Positioned(top: 8, right: 8, child: GestureDetector(onTap: onDelete, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20)))),
      ],
    );
  }

  Widget _buildToolbarButton(IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    final color = active ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}