import 'package:flutter/material.dart';
import 'package:pro_2/MyFilesPage.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  final List<FileInfo> allFiles;

  const FavoritesPage({Key? key, required this.allFiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesProvider>(context);
    final favoriteFiles = allFiles
        .where((file) => favorites.isFavorite(file.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: favoriteFiles.isEmpty
          ? const Center(
              child: Text(
                'لا توجد ملفات مفضلة',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
                      'تاريخ: ${file.date.toLocal().toString().split(" ")[0]}',
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
                      // هنا يمكنك إضافة فتح الملف أو تحريره مثل MyFilesPage
                    },
                  ),
                );
              },
            ),
    );
  }
}
