import 'package:flutter/material.dart';
import 'package:pro_2/MyFilesPage.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/favorites_provider.dart';
import 'package:pro_2/providers/locale_provider.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/FileEditorPage.dart';
import 'package:pro_2/widgets/ActionButton.dart';

class FavoritesPage extends StatelessWidget {
  final List<FileInfo> allFiles; // جميع الملفات من MyFilesPage

  const FavoritesPage({Key? key, required this.allFiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getText('favorites', lang)),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<FavoritesProvider>(
          builder: (context, favorites, _) {
            final favoriteFiles = allFiles
                .where((file) => favorites.isFavorite(file.id))
                .toList();

            if (favoriteFiles.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.getText('favorites_empty', lang),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return ListView.builder(
              itemCount: favoriteFiles.length,
              itemBuilder: (context, index) {
                final file = favoriteFiles[index];
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
                      '${AppLocalizations.getText('my_files_date', lang)}: ${file.date.toLocal().toString().split(" ")[0]}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite),
                      color: Colors.red,
                      onPressed: () => favorites.toggleFavorite(file.id),
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
    );
  }
}
