import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchAction extends StatelessWidget {
  const SearchAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      tooltip: 'Buscar',
      onPressed: () => context.push('/search'),
    );
  }
}
