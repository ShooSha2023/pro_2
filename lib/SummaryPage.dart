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

    setState(() {
      _isSummarizing = true;
      _summary = '';
    });

    // محاكاة عملية التلخيص
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        switch (_selectedType) {
          case SummaryType.full:
            _summary = AppLocalizations.getText('summary_sample_full', lang);
            break;
          case SummaryType.mainIdeas:
            _summary = AppLocalizations.getText('summary_sample_ideas', lang);
            break;
          case SummaryType.dates:
            _summary = AppLocalizations.getText('summary_sample_dates', lang);
            break;
        }
        _isSummarizing = false;
      });
    });
  }

  void _copySummary() {
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;

    if (_summary.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _summary));
    TopNotification.show(context, AppLocalizations.getText('copy_done', lang));
  }

  Future<void> _saveSummary() async {
    final lang = Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).locale.languageCode;

    if (_summary.isEmpty) return;
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

              // اختيار نوع التلخيص
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SummaryType>(
                    value: _selectedType,
                    isExpanded: true,
                    dropdownColor: theme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: SummaryType.full,
                        child: Text(
                          AppLocalizations.getText('summary_full', lang),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DropdownMenuItem(
                        value: SummaryType.mainIdeas,
                        child: Text(
                          AppLocalizations.getText('summary_main_ideas', lang),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DropdownMenuItem(
                        value: SummaryType.dates,
                        child: Text(
                          AppLocalizations.getText('summary_dates', lang),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
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
