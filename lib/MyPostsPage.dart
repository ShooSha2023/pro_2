// import 'package:flutter/material.dart';
// import 'package:pro_2/contacts.dart';
// import 'package:provider/provider.dart';
// import 'package:pro_2/localization/app_localizations.dart';
// import 'package:pro_2/providers/locale_provider.dart';

// class MyPostsPage extends StatefulWidget {
//   const MyPostsPage({Key? key}) : super(key: key);

//   @override
//   State<MyPostsPage> createState() => _MyPostsPageState();
// }

// class _MyPostsPageState extends State<MyPostsPage> {
//   final List<Map<String, String>> _posts = [
//     {'title': 'تلخيص محاضرة الفيزياء', 'date': '2025-07-30'},
//     {'title': 'تفريغ نقاش المشروع الجماعي', 'date': '2025-07-28'},
//     {'title': 'بحث عن الذكاء الاصطناعي', 'date': '2025-07-25'},
//   ];

//   final List<Map<String, String>> _filesToSend = [
//     {'name': 'ملف 1', 'type': 'Word'},
//     {'name': 'ملف 2', 'type': 'PDF'},
//     {'name': 'ملف 3', 'type': 'Text'},
//   ];

//   void _handleMenuSelection(String value, int index) {
//     // نفس الكود الموجود سابقًا
//   }

//   void _navigateToDetails(Map<String, String> post) {
//     // نفس الكود الموجود سابقًا
//   }

//   void _showSendFilesOverlay() {
//     final selectedFiles = <String>{}; // لتخزين الملفات المحددة مؤقتًا

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'اختر الملفات للإرسال',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     ..._filesToSend.map((file) {
//                       final isSelected = selectedFiles.contains(file['name']);
//                       return CheckboxListTile(
//                         title: Text(file['name']!),
//                         subtitle: Text(file['type']!),
//                         value: isSelected,
//                         onChanged: (val) {
//                           setState(() {
//                             if (val == true) {
//                               selectedFiles.add(file['name']!);
//                             } else {
//                               selectedFiles.remove(file['name']!);
//                             }
//                           });
//                         },
//                         secondary: Icon(
//                           file['type'] == 'PDF'
//                               ? Icons.picture_as_pdf
//                               : file['type'] == 'Word'
//                               ? Icons.article
//                               : Icons.text_snippet,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       );
//                     }).toList(),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               'تم اختيار الملفات: ${selectedFiles.join(', ')}',
//                             ),
//                           ),
//                         );
//                       },
//                       child: const Text('تم'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final localeProvider = Provider.of<LocaleProvider>(context);
//     final lang = localeProvider.locale.languageCode;
//     final primaryColor = Theme.of(context).colorScheme.primary;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.getText('my_posts', lang),
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//         ),
//         backgroundColor: primaryColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: _showSendFilesOverlay,
//             tooltip: AppLocalizations.getText('my_posts_send', lang),
//           ),
//           IconButton(
//             icon: const Icon(Icons.group),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => ContactsPage()),
//               );
//             },
//             tooltip: AppLocalizations.getText('my_posts_users', lang),
//           ),
//         ],
//       ),
//       body: _posts.isEmpty
//           ? Center(
//               child: Text(
//                 AppLocalizations.getText('my_posts_empty', lang),
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _posts.length,
//               itemBuilder: (context, index) {
//                 final post = _posts[index];
//                 return Card(
//                   elevation: 3,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   color: Theme.of(context).cardColor,
//                   child: ListTile(
//                     title: Text(
//                       post['title'] ?? '',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     subtitle: Text(
//                       '📅 ${post['date']}',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodySmall?.copyWith(color: Colors.grey),
//                     ),
//                     leading: Icon(Icons.article_outlined, color: primaryColor),
//                     onTap: () => _navigateToDetails(post),
//                     trailing: PopupMenuButton<String>(
//                       onSelected: (value) => _handleMenuSelection(value, index),
//                       itemBuilder: (BuildContext context) => [
//                         PopupMenuItem(
//                           value: 'edit',
//                           child: ListTile(
//                             leading: const Icon(Icons.edit, color: Colors.blue),
//                             title: Text(
//                               AppLocalizations.getText('my_posts_edit', lang),
//                             ),
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'delete',
//                           child: ListTile(
//                             leading: const Icon(
//                               Icons.delete,
//                               color: Colors.red,
//                             ),
//                             title: Text(
//                               AppLocalizations.getText('my_posts_delete', lang),
//                             ),
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'export',
//                           child: ListTile(
//                             leading: const Icon(
//                               Icons.upload_file,
//                               color: Colors.green,
//                             ),
//                             title: Text(
//                               AppLocalizations.getText('my_posts_export', lang),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

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
  // الحالة الحالية: true -> عرض المرسلة, false -> عرض المستلمة
  bool isSentView = true;

  // مثال بيانات الملفات المرسلة
  final List<Map<String, String>> sentFiles = [
    {'title': 'تلخيص محاضرة الفيزياء', 'date': '2025-07-30'},
    {'title': 'تفريغ نقاش المشروع الجماعي', 'date': '2025-07-28'},
  ];

  // مثال بيانات الملفات المستلمة
  final List<Map<String, String>> receivedFiles = [
    {'title': 'بحث عن الذكاء الاصطناعي', 'date': '2025-07-25'},
    {'title': 'ملخص اجتماع الفريق', 'date': '2025-07-20'},
  ];

  void _navigateToDetails(Map<String, String> file) {
    // هنا تحط الانتقال لصفحة تفاصيل الملف
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // الملفات المعروضة حسب الحالة
    final currentFiles = isSentView ? sentFiles : receivedFiles;

    return Scaffold(
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
          // Toggle بين المرسل والمستلم
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
                    AppLocalizations.getText('my_posts_sent', lang),
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
                    AppLocalizations.getText('my_posts_received', lang),
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
    );
  }
}
