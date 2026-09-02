import 'package:flutter/material.dart';

class ActivityEditorScreen extends StatelessWidget {
  const ActivityEditorScreen({super.key, this.activityId});

  final String? activityId;

  @override
  Widget build(BuildContext context) {
    final isNew = activityId == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Nueva actividad' : 'Editar actividad'),
      ),
      body: const Center(child: Text('Editor de actividad — próximamente')),
    );
  }
}
