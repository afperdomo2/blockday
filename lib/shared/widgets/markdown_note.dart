import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownNote extends StatelessWidget {
  const MarkdownNote({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      data: data,
      styleSheet: MarkdownStyleSheet.fromTheme(theme)
          .copyWith(p: theme.textTheme.bodyMedium),
    );
  }
}
