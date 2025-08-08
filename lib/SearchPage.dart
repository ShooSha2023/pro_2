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

  final Color primaryColor = Color(0xFF8185E2);

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _results =
            List.generate(5, (index) => 'نتيجة ${index + 1} للبحث: "$query"');
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 البحث'),
        backgroundColor: primaryColor,
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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _isSearching
                ? const CircularProgressIndicator()
                : Expanded(
                    child: _results.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد نتائج بعد.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(Icons.description),
                                  title: Text(_results[index]),
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
