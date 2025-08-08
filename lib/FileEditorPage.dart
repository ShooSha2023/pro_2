import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;

class FileEditorPage extends StatefulWidget {
  final String fileName;
  final String fileUrl;

  const FileEditorPage({
    Key? key,
    required this.fileName,
    required this.fileUrl,
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
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        final doc = quill.Document()..insert(0, response.body);
        setState(() {
          _controller = quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
          _isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل الملف');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
      setState(() {
        _controller = quill.QuillController.basic();
        _isLoading = false;
      });
    }
  }

  void _saveFile() {
    if (_controller != null) {
      final content = _controller!.document.toPlainText();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'تم حفظ الملف (محلياً فقط حالياً). طول النص: ${content.length} حرف'),
        ),
      );
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
        title: Text(widget.fileName),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _controller == null ? null : _saveFile,
            tooltip: 'حفظ',
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
                            // autoFocus: true,
                            // readOnly: false,
                            // expands: true,
                            // padding: EdgeInsets.zero,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
