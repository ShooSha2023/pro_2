import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pro_2/FileEditorPage.dart';
import 'package:pro_2/SearchPage.dart';
import 'package:pro_2/favourite.dart';
import 'package:pro_2/widgets/ActionButton.dart';
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

  void _createNewFile(String lang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileEditorPage(
          fileName: AppLocalizations.getText('my_files_new_file', lang),
          fileUrl: '',
        ),
      ),
    );
  }

  void _showExportMenu(FileInfo file, String lang) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Word'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file, lang, 'docx');
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Text'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file, lang, 'txt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
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

    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: Scaffold(
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
              tooltip: AppLocalizations.getText('my_files_search', lang),
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
              tooltip: AppLocalizations.getText('favorites', lang),
            ),
            IconButton(
              icon: const Icon(Icons.note_add),
              onPressed: () => _createNewFile(lang),
              tooltip: AppLocalizations.getText('my_files_create', lang),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<FavoritesProvider>(
            builder: (context, favorites, _) {
              return _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _files.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.getText('my_files_empty', lang),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${AppLocalizations.getText('my_files_date', lang)}: ${file.date.toLocal().toString().split(" ")[0]}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    color: primaryColor,
                                    onPressed: () =>
                                        _showExportMenu(file, lang),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    ),
                                    color: Colors.red,
                                    onPressed: () =>
                                        favorites.toggleFavorite(file.id),
                                  ),
                                ],
                              ),
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
                    );
            },
          ),
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
