import 'package:flutter/material.dart';
import 'package:pro_2/select_shared_files.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Map<String, String>> contacts = [
    {'name': 'أحمد محمد', 'phone': '+970123456789'},
    {'name': 'سارة علي', 'phone': '+970987654321'},
    {'name': 'خالد يوسف', 'phone': '+970112233445'},
  ];

  final Set<int> selectedContacts = {}; // لتخزين الفهارس المختارة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جهات الاتصال'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final isSelected = selectedContacts.contains(index);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).cardColor,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(contact['name']![0]),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              title: Text(contact['name']!),
              subtitle: Text(contact['phone']!),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedContacts.remove(index);
                  } else {
                    selectedContacts.add(index);
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: selectedContacts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                // تمرير قائمة المختارين إلى صفحة اختيار الملفات
                final selected = selectedContacts
                    .map((i) => contacts[i])
                    .toList();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      SendFilesOverlay(selectedContacts: selected),
                );
              },
              label: const Text(
                'التالي',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
    );
  }
}
