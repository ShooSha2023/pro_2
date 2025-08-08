import 'package:flutter/material.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final Color primaryColor = const Color(0xFF8185E2);

  final List<Map<String, String>> _posts = [
    {
      'title': 'تلخيص محاضرة الفيزياء',
      'date': '2025-07-30',
    },
    {
      'title': 'تفريغ نقاش المشروع الجماعي',
      'date': '2025-07-28',
    },
    {
      'title': 'بحث عن الذكاء الاصطناعي',
      'date': '2025-07-25',
    },
  ];

  void _handleMenuSelection(String value, int index) {
    switch (value) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قيد التطوير: تعديل')),
        );
        break;
      case 'delete':
        setState(() {
          _posts.removeAt(index);
        });
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التصدير بنجاح')),
        );
        break;
    }
  }

  void _navigateToDetails(Map<String, String> post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فتح: ${post['title']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 مشاركاتي'),
        backgroundColor: primaryColor,
      ),
      body: _posts.isEmpty
          ? const Center(
              child: Text(
                'لا توجد مشاركات بعد.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(post['title'] ?? ''),
                    subtitle: Text('📅 ${post['date']}'),
                    leading: const Icon(Icons.article_outlined,
                        color: Colors.indigo),
                    onTap: () => _navigateToDetails(post),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuSelection(value, index),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.blue),
                            title: Text('تعديل'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('حذف'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'export',
                          child: ListTile(
                            leading:
                                Icon(Icons.upload_file, color: Colors.green),
                            title: Text('تصدير'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
