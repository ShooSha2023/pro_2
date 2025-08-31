import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pro_2/FileEditorPage.dart';
import 'package:pro_2/SearchPage.dart';
import 'package:pro_2/favourite.dart';
import 'package:pro_2/providers/favorites_provider.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/locale_provider.dart';

class MyFilesPage extends StatefulWidget {
  const MyFilesPage({Key? key}) : super(key: key);

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  bool _isLoading = true;
  List<FileInfo> _files = [];

  @override
  void initState() {
    super.initState();
    _fetchFilesFromServer();
  }

  Future<void> _fetchFilesFromServer() async {
    await Future.delayed(const Duration(seconds: 2));
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

  Future<void> _downloadFile(FileInfo file, String lang, String format) async {
    try {
      final response = await http.get(Uri.parse(file.url));
      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final extension = format.toLowerCase();
        final filePath =
            '${directory?.path}/${file.name.split(".")[0]}.$extension';
        final localFile = File(filePath);
        await localFile.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.getText('my_files_saved', lang)}: $filePath',
            ),
          ),
        );
      } else {
        throw Exception(
          AppLocalizations.getText('my_files_failed_download', lang),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.getText('my_files_error', lang)}: $e',
          ),
        ),
      );
    }
  }

  void _openEditor({String? initialText, String? fileName}) async {
    final editedText = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FileEditorPage(
          fileName: fileName ?? 'ملف جديد',
          initialText: initialText ?? '',
        ),
      ),
    );

    if (editedText != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
    }
  }

  void _createNewFile(String lang) {
    _openEditor(
      initialText: '',
      fileName: AppLocalizations.getText('my_files_new_file', lang),
    );
  }

  void _showExportMenu(FileInfo file, String lang) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.article, color: theme.colorScheme.primary),
              title: Text(
                'Word',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file, lang, 'docx');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.text_snippet,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Text',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file, lang, 'txt');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.picture_as_pdf,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'PDF',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file, lang, 'pdf');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    final favorites = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getText('my_files', lang)),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(allFiles: _files),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () => _createNewFile(lang),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _files.isEmpty
            ? Center(
                child: Text(AppLocalizations.getText('my_files_empty', lang)),
              )
            : ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final isFavorite = favorites.isFavorite(file.id);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                      title: Text(
                        file.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'تاريخ: ${file.date.toLocal().toString().split(" ")[0]}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            color: primaryColor,
                            onPressed: () => _showExportMenu(file, lang),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            color: Colors.red,
                            onPressed: () => favorites.toggleFavorite(file.id),
                          ),
                        ],
                      ),
                      onTap: () async {
                        try {
                          final response = await http.get(Uri.parse(file.url));
                          String fileContent = '';
                          if (response.statusCode == 200) {
                            fileContent = response.body;
                          }
                          _openEditor(
                            initialText: fileContent,
                            fileName: file.name,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ عند تحميل الملف: $e')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

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
