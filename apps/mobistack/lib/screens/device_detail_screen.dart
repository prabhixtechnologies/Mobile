import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<AppState>().devices;
    final match = devices.where((d) => d.id == deviceId);
    final device = match.isEmpty ? null : match.first;
    return Scaffold(
      appBar: AppBar(title: Text(device?.name ?? 'Device')),
      body: device == null
          ? const Center(child: Text('Device not in local snapshot.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(device.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Brand: ${device.brandName ?? '—'}'),
                Text('Model: ${device.modelCode ?? '—'}'),
                Text('Id: ${device.id}'),
              ],
            ),
    );
  }
}
