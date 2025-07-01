import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'dart:async';

class FutureNoteOverlayInput extends StatefulWidget {
  final DateTime date;
  const FutureNoteOverlayInput({super.key, required this.date});

  @override
  State<FutureNoteOverlayInput> createState() => _FutureNoteOverlayInputState();
}

class _FutureNoteOverlayInputState extends State<FutureNoteOverlayInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _loading = true;
  bool _saving = false;
  String? _status;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _loadNote();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final entry = await HiveDayStorage.retrieveDay(widget.date);
    setState(() {
      _controller.text = entry?['future_note'] ?? '';
      _loading = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _saveNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _status = null;
        _saving = false;
      });
      return;
    }
    setState(() { _saving = true; });
    final entry = await HiveDayStorage.retrieveDay(widget.date) ?? {
      'date': widget.date,
      'note': '',
      'rating': null,
      'pictures': <String>[],
      'future_note': '',
    };
    entry['future_note'] = text;
    await HiveDayStorage.storeDay(widget.date, entry);
    setState(() {
      _status = 'Saved!';
      _saving = false;
    });
  }

  void _onTextChanged() {
    setState(() => _status = null);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (mounted) _saveNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          // minLines: 4,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // isDense: true,
          ),
        ),
      ],
    );
  }
}
