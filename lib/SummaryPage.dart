import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_2/services/api.dart';
import 'package:pro_2/widgets/ActionButton.dart';
import 'package:pro_2/widgets/top_notification.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/locale_provider.dart';
import 'package:loading_overlay/loading_overlay.dart';

enum SummaryType { full, mainIdeas, dates }

enum TextType { article, conversation, report }

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController _inputController = TextEditingController();
  String _summary = '';
  bool _isSummarizing = false;

  SummaryType _selectedType = SummaryType.full;
  TextType? _selectedTextType;

  final Map<SummaryType, List<TextType>> _textTypeOptions = {
    SummaryType.full: [
      TextType.article,
      TextType.conversation,
      TextType.report,
    ],
    SummaryType.mainIdeas: [],
    SummaryType.dates: [],
  };

  String safeText(String key, String fallback, String lang) {
    final val = AppLocalizations.getText(key, lang);
    if (val == null) {
      print("⚠️ Missing translation for key: $key (lang: $lang)");
    }
    return val ?? fallback;
  }

  void _summarizeText() async {
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;

    if (_inputController.text.trim().isEmpty) {
      TopNotification.show(
        context,
        safeText('empty_input_warning', 'Input is empty', lang),
        type: NotificationType.error,
      );
      return;
    }

    if (_selectedType == SummaryType.full && _selectedTextType == null) {
      TopNotification.show(
        context,
        safeText('select_text_type', 'Please select text type', lang),
        type: NotificationType.error,
      );
      return;
    }

    setState(() {
      _isSummarizing = true;
      _summary = '';
    });

    String summaryTypeStr;
    switch (_selectedType) {
      case SummaryType.full:
        summaryTypeStr = "كامل";
        break;
      case SummaryType.mainIdeas:
        summaryTypeStr = "أفكار رئيسية";
        break;
      case SummaryType.dates:
        summaryTypeStr = "أحداث";
        break;
    }

    String? textTypeStr;
    if (_selectedType == SummaryType.full && _selectedTextType != null) {
      switch (_selectedTextType!) {
        case TextType.article:
          textTypeStr = "مقال";
          break;
        case TextType.conversation:
          textTypeStr = "محادثة";
          break;
        case TextType.report:
          textTypeStr = "تقرير";
          break;
      }
    }

    print("📦 Sending summaryType: $summaryTypeStr, textType: $textTypeStr");

    final response = await ApiService.summarizeText(
      text: _inputController.text.trim(),
      summaryType: summaryTypeStr,
      textType: textTypeStr,
    );

    print("📥 Summarize response: $response");

    setState(() {
      _isSummarizing = false;

      if (response["success"] == true) {
        final data = response["data"];
        if (data != null) {
          if (data["bullets"] != null &&
              data["bullets"] is List &&
              data["bullets"].isNotEmpty) {
            _summary = (data["bullets"] as List).map((e) => "• $e").join("\n");
          } else if (data["facts"] != null &&
              data["facts"] is List &&
              data["facts"].isNotEmpty) {
            _summary = (data["facts"] as List).map((e) => "- $e").join("\n");
          } else if (data["summary"] != null) {
            _summary = data["summary"];
          } else {
            _summary = safeText(
              'no_summary_returned',
              'No summary returned',
              lang,
            );
          }
        } else {
          _summary = safeText(
            'no_summary_returned',
            'No summary returned',
            lang,
          );
        }
      } else {
        print("❌ Summarize error: ${response["error"]}");
        TopNotification.show(
          context,
          "خطأ: ${response["error"].toString()}",
          type: NotificationType.error,
        );
      }
    });
  }

  void _copySummary() {
    if (_summary.trim().isEmpty) {
      print("⚠️ Cannot copy empty summary");
      return;
    }
    Clipboard.setData(ClipboardData(text: _summary));
    print("✅ Copied summary to clipboard");
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;
    TopNotification.show(
      context,
      safeText('copy_done', 'Copied successfully', lang),
    );
  }

  Future<void> _saveSummary() async {
    if (_summary.trim().isEmpty) {
      print("⚠️ Cannot save empty summary");
      return;
    }
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/summary.txt');
      await file.writeAsString(_summary);
      print("✅ Saved summary at ${file.path}");
      TopNotification.show(
        context,
        "${safeText('save_done', 'Saved', lang)}: ${file.path}",
      );
    } catch (e) {
      print("❌ Save error: $e");
      TopNotification.show(
        context,
        "${safeText('save_error', 'Save error', lang)}: $e",
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: LoadingOverlay(
        isLoading: _isSummarizing,
        color: Colors.black.withOpacity(0.5),
        progressIndicator: const CircularProgressIndicator(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(safeText('summary_title', 'Summary', lang)),
            backgroundColor: theme.colorScheme.primary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _inputController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: safeText(
                      'input_hint',
                      'Enter text to summarize',
                      lang,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    fillColor: theme.cardColor,
                    filled: true,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButton<SummaryType>(
                  value: _selectedType,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        if (_selectedType != SummaryType.full) {
                          _selectedTextType = null;
                        }
                      });
                    }
                  },
                  items: SummaryType.values.map((type) {
                    String label;
                    switch (type) {
                      case SummaryType.full:
                        label = safeText('full_text', 'Full text', lang);
                        break;
                      case SummaryType.mainIdeas:
                        label = safeText(
                          'summary_main_ideas',
                          'Main ideas',
                          lang,
                        );
                        break;
                      case SummaryType.dates:
                        label = safeText('dates', 'Dates', lang);
                        break;
                    }
                    return DropdownMenuItem(
                      value: type,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                if (_selectedType == SummaryType.full)
                  DropdownButton<TextType>(
                    value: _selectedTextType,
                    hint: Text(
                      safeText('select_text_type', 'Select text type', lang),
                      overflow: TextOverflow.ellipsis,
                    ),
                    isExpanded: true,
                    onChanged: (value) =>
                        setState(() => _selectedTextType = value),
                    items: _textTypeOptions[SummaryType.full]!.map((textType) {
                      String label;
                      switch (textType) {
                        case TextType.article:
                          label = safeText('article', 'Article', lang);
                          break;
                        case TextType.conversation:
                          label = safeText(
                            'conversation',
                            'Conversation',
                            lang,
                          );
                          break;
                        case TextType.report:
                          label = safeText('report', 'Report', lang);
                          break;
                      }
                      return DropdownMenuItem(
                        value: textType,
                        child: Text(label, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                ActionButton(
                  color: theme.colorScheme.primary,
                  icon: Icons.auto_awesome,
                  label: _isSummarizing
                      ? safeText('summarizing', 'Summarizing', lang)
                      : safeText('summarize', 'Summarize', lang),
                  onPressed: _isSummarizing ? null : _summarizeText,
                ),
                const SizedBox(height: 20),
                // ✅ Display summary in a scrollable container
                if (_summary.isNotEmpty || _isSummarizing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _isSummarizing
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Text(
                              _summary,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                  ),
                const SizedBox(height: 10),
                // ✅ Buttons outside Expanded
                if (!_isSummarizing && _summary.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ActionButton(
                          color: theme.colorScheme.primary,
                          icon: Icons.copy,
                          label: safeText('copy', 'Copy', lang),
                          onPressed: _summary.trim().isEmpty
                              ? null
                              : _copySummary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ActionButton(
                          color: theme.colorScheme.primary,
                          icon: Icons.save,
                          label: safeText('save', 'Save', lang),
                          onPressed: _summary.trim().isEmpty
                              ? null
                              : _saveSummary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
