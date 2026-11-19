import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'markdown_note.dart';

class NotesField extends StatefulWidget {
  const NotesField({
    super.key,
    required this.controller,
    this.labelText = 'Notas',
    this.hintText,
    this.maxLines = 4,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int maxLines;

  @override
  State<NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<NotesField> {
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!_preview) {
      return TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
          hintText: widget.hintText,
          suffixIcon: IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Vista previa',
            onPressed: () => setState(() => _preview = true),
          ),
        ),
        maxLines: widget.maxLines,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.labelText,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _preview = false),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (widget.controller.text.trim().isEmpty)
            Text(
              'Sin notas',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            MarkdownNote(data: widget.controller.text),
        ],
      ),
    );
  }
}
