import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blockday')),
      body: const Center(child: Text('Vista de día — próximamente')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Nueva actividad',
        child: const Icon(Icons.add),
      ),
    );
  }
}
