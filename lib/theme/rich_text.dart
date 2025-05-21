// lib/widgets/rich_text_editor.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/services.dart';
import 'app_theme.dart';

class RichTextEditor extends StatefulWidget {
  final quill.QuillController controller;
  final String label;
  final _controller = quill.QuillController.basic();
final _focusNode = FocusNode();

   RichTextEditor({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                  controller: widget.controller,
                  sharedConfigurations: const quill.QuillSharedConfigurations(),
                  multiRowsDisplay: false,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: quill.QuillEditor.basic(
                  configurations: quill.QuillEditorConfigurations(
                    controller: widget.controller,
                    sharedConfigurations: const quill.QuillSharedConfigurations(),
                    enableInteractiveSelection: true,
                    scrollable: true,
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
