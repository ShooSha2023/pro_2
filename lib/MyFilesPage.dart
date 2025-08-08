import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pro_2/FileEditorPage.dart';

import 'package:pro_2/SearchPage.dart';

class MyFilesPage extends StatefulWidget {
  const MyFilesPage({Key? key}) : super(key: key);

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  final Color primaryColor = const Color(0xFF8185E2);
  bool _isLoading = true;
  List<FileInfo> _files = [];

  @override
  void initState() {
    super.initState();
    _fetchFilesFromServer();
  }

  Future<void> _fetchFilesFromServer() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _files = [
        FileInfo(
          id: '1',
          name: 'تلخيص1.txt',
          url: 'https://example.com/files/summary1.txt',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        FileInfo(
          id: '2',
          name: 'تفريغ1.txt',
          url: 'https://example.com/files/transcription1.txt',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _downloadFile(FileInfo file) async {
    try {
      final response = await http.get(Uri.parse(file.url));
      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/${file.name}';
        final localFile = File(filePath);
        await localFile.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم حفظ الملف في: $filePath')));
      } else {
        throw Exception('فشل تحميل الملف من السيرفر');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تحميل الملف: $e')));
    }
  }

  void _createNewFile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const FileEditorPage(fileName: 'ملف جديد.txt', fileUrl: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفاتي'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('بحث'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تنفيذ التصدير')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('تصدير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createNewFile,
                  icon: const Icon(Icons.note_add),
                  label: const Text('إنشاء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _files.isEmpty
                  ? const Center(child: Text('لا توجد ملفات.'))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              file.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'تاريخ: ${file.date.toLocal().toString().split(" ")[0]}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.download, color: primaryColor),
                              onPressed: () => _downloadFile(file),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FileEditorPage(
                                    fileName: file.name,
                                    fileUrl: file.url,
                                  ),
                                ),
                              );
                            },
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

// هذا لمودل مشان نربط الباك لنرجع نحطو بملف تاني
class FileInfo {
  final String id;
  final String name;
  final String url;
  final DateTime date;

  FileInfo({
    required this.id,
    required this.name,
    required this.url,
    required this.date,
  });
}
