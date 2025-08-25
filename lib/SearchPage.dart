import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _results = [];
  bool _isSearching = false;

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _results = List.generate(
          5,
          (index) => 'نتيجة ${index + 1} للبحث: "$query"',
        );
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 البحث'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'أدخل كلمة للبحث...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.onSurface),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _isSearching
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _results.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد نتائج بعد.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: theme.cardColor,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.description,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(
                                    _results[index],
                                    style: theme.textTheme.bodyMedium,
                                  ),
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
