import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class RichTextEditor extends StatefulWidget {
  final String? initialContent;
  final bool readOnly;
  final Function(String)? onContentChanged;

  const RichTextEditor({
    Key? key,
    this.initialContent,
    this.readOnly = false,
    this.onContentChanged,
  }) : super(key: key);

  @override
  _RichTextEditorState createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        final doc = quill.Document.fromJson(jsonDecode(widget.initialContent!));
        _controller = quill.QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      } catch (e) {
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
    }

    if (!widget.readOnly && widget.onContentChanged != null) {
      _controller.addListener(() {
        final json = jsonEncode(_controller.document.toDelta().toJson());
        widget.onContentChanged!(json);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.readOnly)
          quill.QuillToolbar.basic(controller: _controller),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)),
            child: quill.QuillEditor(
              controller: _controller,
              readOnly: widget.readOnly,
              scrollController: ScrollController(),
              scrollable: true,
              focusNode: FocusNode(),
              autoFocus: false,
              expands: true,
              padding: EdgeInsets.zero,
              placeholder: widget.readOnly ? null : 'Enter rich text here',
            ),
          ),
        ),
      ],
    );
  }
}
