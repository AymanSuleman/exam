// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';

// class RichTextEditor extends StatefulWidget {
//   final String? initialContent;
//   final bool readOnly;
//   final Function(String)? onContentChanged;

//   const RichTextEditor({
//     Key? key,
//     this.initialContent,
//     this.readOnly = false,
//     this.onContentChanged,
//   }) : super(key: key);

//   @override
//   _RichTextEditorState createState() => _RichTextEditorState();
// }

// class _RichTextEditorState extends State<RichTextEditor> {
//   late QuillController _controller;
//   late final FocusNode _focusNode;
//   late final ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
//       try {
//         final doc = Document.fromJson(jsonDecode(widget.initialContent!));
//         _controller = QuillController(
//           document: doc,
//           selection: const TextSelection.collapsed(offset: 0),
//         );
//       } catch (_) {
//         _controller = QuillController.basic();
//       }
//     } else {
//       _controller = QuillController.basic();
//     }

//     _focusNode = FocusNode();
//     _scrollController = ScrollController();

//     if (!widget.readOnly && widget.onContentChanged != null) {
//       _controller.addListener(() {
//         final json = jsonEncode(_controller.document.toDelta().toJson());
//         widget.onContentChanged!(json);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _scrollController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (!widget.readOnly)
//           QuillToolbar.basic(controller: _controller),
//         const SizedBox(height: 8),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: QuillEditor(
//               controller: _controller,
//               readOnly: widget.readOnly,
//               scrollController: _scrollController,
//               scrollable: true,
//               focusNode: _focusNode,
//               autoFocus: false,
//               expands: true,
//               padding: EdgeInsets.zero,
//               placeholder: widget.readOnly ? null : 'Enter rich text here',
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
