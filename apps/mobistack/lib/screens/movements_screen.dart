import 'package:flutter/material.dart';

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock movements')),
      body: const Center(child: Text('Stock in / out / transfers after sync.')),
    );
  }
}
