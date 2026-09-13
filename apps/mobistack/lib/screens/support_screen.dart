import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Contact Prabhix support or open a ticket from the web console.'),
      ),
    );
  }
}
