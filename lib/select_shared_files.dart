import 'package:flutter/material.dart';

class SendFilesOverlay extends StatefulWidget {
  const SendFilesOverlay({super.key, selectedContacts});

  @override
  State<SendFilesOverlay> createState() => _SendFilesOverlayState();
}

class _SendFilesOverlayState extends State<SendFilesOverlay> {
  final List<Map<String, String>> _filesToSend = List.generate(
    50,
    (index) => {
      'name': 'ملف ${index + 1}',
      'type': index % 3 == 0
          ? 'Word'
          : index % 3 == 1
          ? 'PDF'
          : 'Text',
    },
  );

  final Set<String> selectedFiles = {};
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredFiles = _filesToSend
        .where(
          (file) =>
              file['name']!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر الملفات للإرسال',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن ملف...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var f in filteredFiles)
                        selectedFiles.add(f['name']!);
                    });
                  },
                  child: const Text('تحديد الكل'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var f in filteredFiles)
                        selectedFiles.remove(f['name']!);
                    });
                  },
                  child: const Text('إلغاء الكل'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFiles.length,
                itemBuilder: (context, index) {
                  final file = filteredFiles[index];
                  final isSelected = selectedFiles.contains(file['name']);
                  return ListTile(
                    title: Text(file['name']!),
                    subtitle: Text(file['type']!),
                    leading: Icon(
                      file['type'] == 'PDF'
                          ? Icons.picture_as_pdf
                          : file['type'] == 'Word'
                          ? Icons.article
                          : Icons.text_snippet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedFiles.remove(file['name']!);
                        } else {
                          selectedFiles.add(file['name']!);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم اختيار الملفات: ${selectedFiles.join(', ')}',
                    ),
                  ),
                );
              },
              child: const Text('تم'),
            ),
          ],
        ),
      ),
    );
  }
}
