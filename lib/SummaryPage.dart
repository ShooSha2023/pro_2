import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pro_2/widgets/top_notification.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController _inputController = TextEditingController();
  String _summary = '';
  bool _isSummarizing = false;

  final Color primaryColor = Color(0xFF8185E2);

  void _summarizeText() {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isSummarizing = true;
      _summary = '';
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _summary = 'هذا تلخيص تجريبي للنص المدخل.';
        _isSummarizing = false;
      });
    });
  }

  void _copySummary() {
    if (_summary.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _summary));
    TopNotification.show(context, 'تم نسخ التلخيص');
  }

  Future<void> _saveSummary() async {
    if (_summary.isEmpty) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/summary.txt');
      await file.writeAsString(_summary);
      TopNotification.show(context, 'تم حفظ التلخيص في ${file.path}');
    } catch (e) {
      TopNotification.show(
        context,
        'حدث خطأ أثناء الحفظ: $e',
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 التلخيص'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'أدخل النص هنا ليتم تلخيصه...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSummarizing ? null : _summarizeText,
              icon: const Icon(Icons.auto_awesome),
              label: Text(_isSummarizing ? 'جاري التلخيص...' : 'تلخيص'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_summary.isNotEmpty || _isSummarizing)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _isSummarizing
                          ? const Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _summary,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                      const SizedBox(height: 10),
                      if (!_isSummarizing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _copySummary,
                              icon: const Icon(Icons.copy),
                              label: const Text('نسخ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _saveSummary,
                              icon: const Icon(Icons.save),
                              label: const Text('حفظ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
