import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:pro_2/widgets/top_notification.dart';

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({Key? key}) : super(key: key);

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  File? _audioFile;
  String _transcribedText = '';
  bool _isProcessing = false;

  final Color primaryColor = const Color(0xFF8185E2);

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final ext = path.extension(file.path).toLowerCase();

      if (ext != '.mp3' && ext != '.wav') {
        _showMessage('صيغة غير مدعومة. الرجاء اختيار ملف MP3 أو WAV فقط.');
        return;
      }

      setState(() {
        _audioFile = file;
        _transcribedText = '';
        _isProcessing = true;
      });

      // محاكاة معالجة الملف وتفريغه
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isProcessing = false;
          _transcribedText =
              'مرحبًا، هذا هو النص الناتج عن تفريغ الملف الصوتي التجريبي.';
        });
      });
    }
  }

  void _saveTranscription() {
    if (_transcribedText.isEmpty || _isProcessing) {
      TopNotification.show(context, 'لا يوجد نص لحفظه');
      return;
    }

    TopNotification.show(context, 'تم حفظ النص بنجاح!');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎧 تفريغ ملف صوتي'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('اختر ملف صوتي (.mp3 أو .wav)'),
              onPressed: _pickAudioFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_audioFile != null)
              Text(
                'تم اختيار الملف: ${path.basename(_audioFile!.path)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _transcribedText.isEmpty
                              ? 'سيظهر النص هنا بعد اختيار الملف الصوتي...'
                              : _transcribedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: _saveTranscription,
                icon: const Icon(Icons.save),
                label: const Text('حفظ النص'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
