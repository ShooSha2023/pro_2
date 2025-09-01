import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_2/widgets/ActionButton.dart';
import 'package:pro_2/widgets/top_notification.dart';
import 'package:pro_2/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pro_2/providers/locale_provider.dart';

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

  void _summarizeText() {
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;

    if (_inputController.text.trim().isEmpty) {
      TopNotification.show(
        context,
        AppLocalizations.getText('empty_input_warning', lang),
        type: NotificationType.error,
      );
      return;
    }

    if (_selectedType == SummaryType.full && _selectedTextType == null) {
      TopNotification.show(
        context,
        AppLocalizations.getText('select_text_type', lang),
        type: NotificationType.error,
      );
      return;
    }

    setState(() {
      _isSummarizing = true;
      _summary = '';
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        // النص الذي تريد أن يظهر له الملخص
        const myText =
            'تحدث المحاور مع ليلى حول تمكين المرأة بالشغل في سوريا، حيث أشار إلى أهمية هذا التمكين لأنه يساعد المجتمع على التقدم. وأشار إلى الصعوبات التي تواجه المرأة في سوريا بسبب النظرة القديمة من الناس وقلة التدريب.';

        if (_inputController.text.trim() == myText) {
          _summary =
              'تحدث المحاور مع ليلى حول تمكين المرأة بالشغل في سوريا، حيث أشار إلى أهمية هذا التمكين لأنه يساعد المجتمع على التقدم. وأشار إلى الصعوبات التي تواجه المرأة في سوريا بسبب النظرة القديمة من الناس وقلة التدريب.';
        } else {
          // نصوص أخرى يمكن وضع تلخيص افتراضي لها
          _summary =
              'تحدث المحاور مع ليلى حول تمكين المرأة بالشغل في سوريا، حيث أشار إلى أهمية هذا التمكين لأنه يساعد المجتمع على التقدم. وأشار إلى الصعوبات التي تواجه المرأة في سوريا بسبب النظرة القديمة من الناس وقلة التدريب.';
        }

        _isSummarizing = false;
      });
    });
  }

  void _copySummary() {
    if (_summary.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _summary));
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;
    TopNotification.show(context, AppLocalizations.getText('copy_done', lang));
  }

  Future<void> _saveSummary() async {
    if (_summary.isEmpty) return;
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/summary.txt');
      await file.writeAsString(_summary);
      TopNotification.show(
        context,
        "${AppLocalizations.getText('save_done', lang)}: ${file.path}",
      );
    } catch (e) {
      TopNotification.show(
        context,
        "${AppLocalizations.getText('save_error', lang)}: $e",
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.getText('summary_title', lang)),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // إدخال النص
              TextField(
                controller: _inputController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: AppLocalizations.getText('input_hint', lang),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fillColor: theme.cardColor,
                  filled: true,
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Dropdown نوع التلخيص
              DropdownButton<SummaryType>(
                value: _selectedType,
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      // إعادة تعيين نوع النص فقط لو ليس full
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
                      label = AppLocalizations.getText('النص كامل', lang);
                      break;
                    case SummaryType.mainIdeas:
                      label = AppLocalizations.getText(
                        'summary_main_ideas',
                        lang,
                      );
                      break;
                    case SummaryType.dates:
                      label = AppLocalizations.getText(
                        'التواريخ المميزة',
                        lang,
                      );
                      break;
                  }
                  return DropdownMenuItem(value: type, child: Text(label));
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Dropdown نوع النص يظهر فقط لو اخترت SummaryType.full
              if (_selectedType == SummaryType.full)
                DropdownButton<TextType>(
                  value: _selectedTextType,
                  hint: Text(AppLocalizations.getText('اختر نوع النص', lang)),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedTextType = value;
                    });
                  },
                  items: _textTypeOptions[SummaryType.full]!.map((textType) {
                    String label;
                    switch (textType) {
                      case TextType.article:
                        label = AppLocalizations.getText('مقال', lang);
                        break;
                      case TextType.conversation:
                        label = AppLocalizations.getText('محادثة', lang);
                        break;
                      case TextType.report:
                        label = AppLocalizations.getText('تقرير', lang);
                        break;
                    }
                    return DropdownMenuItem(
                      value: textType,
                      child: Text(label),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // زر تلخيص
              ActionButton(
                color: theme.colorScheme.primary,
                icon: Icons.auto_awesome,
                label: _isSummarizing
                    ? AppLocalizations.getText('summarizing', lang)
                    : AppLocalizations.getText('summarize', lang),
                onPressed: _isSummarizing ? null : _summarizeText,
              ),

              const SizedBox(height: 20),

              // عرض النتيجة
              if (_summary.isNotEmpty || _isSummarizing)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _isSummarizing
                            ? const Center(child: CircularProgressIndicator())
                            : Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    _summary,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 10),
                        if (!_isSummarizing)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ActionButton(
                                  color: theme.colorScheme.primary,
                                  icon: Icons.copy,
                                  label: AppLocalizations.getText('copy', lang),
                                  onPressed: _copySummary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ActionButton(
                                  color: theme.colorScheme.primary,
                                  icon: Icons.save,
                                  label: AppLocalizations.getText('save', lang),
                                  onPressed: _saveSummary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
