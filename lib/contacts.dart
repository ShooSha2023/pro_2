import 'package:flutter/material.dart';
import 'package:pro_2/select_shared_files.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/services/token_manager.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, dynamic>> contacts = []; // بيانات المستخدمين من السيرفر
  List<Map<String, dynamic>> filteredContacts = [];
  final Set<int> selectedContacts = {}; // لتخزين الفهارس المختارة
  bool _isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await ApiService.getRecipients(token);

    setState(() => _isLoading = false);

    if (result['success']) {
      contacts = List<Map<String, dynamic>>.from(result['data']['results']);
      _filterContacts();
    } else {
      print("Failed to load contacts: ${result['error']}");
    }
  }

  void _filterContacts() {
    if (searchQuery.isEmpty) {
      filteredContacts = List.from(contacts);
    } else {
      filteredContacts = contacts.where((contact) {
        final name =
            ((contact['first_name'] ?? '') + ' ' + (contact['last_name'] ?? ''))
                .toLowerCase();
        final email = (contact['email'] ?? '').toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جهات الاتصال'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث باسم المستخدم أو الإيميل',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                searchQuery = value;
                _filterContacts();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      final isSelected = selectedContacts.contains(index);

                      final displayName =
                          ((contact['first_name'] ?? '') +
                                  ' ' +
                                  (contact['last_name'] ?? ''))
                              .trim();
                      final email = contact['email'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2)
                            : Theme.of(context).cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0]
                                  : email[0],
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                          ),
                          title: Text(
                            displayName.isNotEmpty ? displayName : email,
                          ),
                          subtitle: Text(email),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
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
          ),
        ],
      ),
      floatingActionButton: selectedContacts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                final selected = selectedContacts
                    .map((i) => filteredContacts[i])
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
