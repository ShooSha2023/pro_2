import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class FileEditorPage extends StatefulWidget {
  final String? fileName;
  final String? fileUrl;
  final String? initialText;

  const FileEditorPage({
    Key? key,
    this.fileName,
    this.fileUrl,
    this.initialText,
  }) : super(key: key);

  @override
  State<FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends State<FileEditorPage> {
  quill.QuillController? _controller;
  bool _isLoading = true;
  final Color primaryColor = const Color(0xFF8185E2);

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.initialText != null) {
      // حالة نص مبدئي أو تفريغ صوتي
      final doc = quill.Document()..insert(0, widget.initialText!);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _isLoading = false;
    } else if (widget.fileUrl != null) {
      // حالة فتح ملف موجود من URL (يمكن لاحقاً إضافة تحميل HTTP)
      // الآن نتركها فارغة مؤقتاً
      final doc = quill.Document()
        ..insert(0, 'تحميل الملف من الرابط: ${widget.fileUrl}');
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _isLoading = false;
    } else {
      // حالة إنشاء جديد بدون نص
      _controller = quill.QuillController.basic();
      _isLoading = false;
    }
  }

  void _saveAndReturn() {
    if (_controller != null) {
      final content = _controller!.document.toPlainText();
      Navigator.pop(context, content); // يرجع النص للصفحة السابقة
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName ?? 'محرر النصوص'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'حفظ',
            onPressed: _saveAndReturn,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_controller != null)
                  quill.QuillSimpleToolbar(controller: _controller!),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: _controller == null
                        ? const Center(child: Text('لا يوجد محتوى'))
                        : quill.QuillEditor.basic(
                            controller: _controller!,
                            focusNode: _focusNode,
                            scrollController: _scrollController,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
