import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/contacts.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:pro_2/providers/locale_provider.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool isSentView = true; // true -> عرض المرسلة, false -> عرض المستلمة

  final List<Map<String, String>> sentFiles = [
    {'title': 'تلخيص مقابلة مع الانسة لمياء', 'date': '2025-07-30'},
    {'title': 'تفريغ برنامج صباح الخير', 'date': '2025-07-28'},
  ];

  final List<Map<String, String>> receivedFiles = [
    {'title': 'بحث عن الذكاء الاصطناعي', 'date': '2025-07-25'},
    {'title': 'ملخص اجتماع الفريق', 'date': '2025-07-20'},
  ];

  void _navigateToDetails(Map<String, String> file) {
    // هنا يمكن إضافة الانتقال إلى صفحة تفاصيل الملف
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textDirection = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    final currentFiles = isSentView ? sentFiles : receivedFiles;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.getText('my_posts', lang),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: primaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactsPage()),
                );
              },
              tooltip: AppLocalizations.getText('my_posts_users', lang),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            // Toggle بين الملفات المرسلة والمستلمة
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isSentView = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSentView ? primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.getText('sent_files', lang),
                      style: TextStyle(
                        color: isSentView ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => isSentView = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: !isSentView ? primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.getText('received_files', lang),
                      style: TextStyle(
                        color: !isSentView ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: currentFiles.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.getText('my_posts_empty', lang),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: currentFiles.length,
                      itemBuilder: (context, index) {
                        final file = currentFiles[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Theme.of(context).cardColor,
                          child: ListTile(
                            title: Text(
                              file['title'] ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              '📅 ${file['date']}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            leading: Icon(
                              Icons.article_outlined,
                              color: primaryColor,
                            ),
                            onTap: () => _navigateToDetails(file),
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
