import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<AppState>().devices.where((d) {
      final q = _query.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return '${d.name} ${d.brandName ?? ''} ${d.modelCode ?? ''}'.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Compatibility')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _query,
              decoration: const InputDecoration(
                hintText: 'Search a phone…',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = devices[i];
                return ListTile(
                  title: Text(d.name),
                  subtitle: Text([if (d.brandName != null) d.brandName!, if (d.modelCode != null) d.modelCode!].join(' · ')),
                  onTap: () => context.push('/devices/${d.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
