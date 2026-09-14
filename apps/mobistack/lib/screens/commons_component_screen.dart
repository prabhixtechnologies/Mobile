import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/chrome.dart';
import '../widgets/live_api_list.dart';
import '../widgets/shop_ui.dart';

class CommonsComponentScreen extends StatefulWidget {
  const CommonsComponentScreen({super.key, required this.componentId});

  final String componentId;

  @override
  State<CommonsComponentScreen> createState() => _CommonsComponentScreenState();
}

class _CommonsComponentScreenState extends State<CommonsComponentScreen> {
  Map<String, dynamic>? _component;
  List<Map<String, dynamic>> _devices = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    try {
      final component =
          await state.api.dio.get<dynamic>('commons/components/${widget.componentId}');
      final devices =
          await state.api.dio.get<dynamic>('commons/components/${widget.componentId}/devices');
      if (!mounted) return;
      setState(() {
        _component = component.data is Map
            ? Map<String, dynamic>.from(component.data as Map)
            : null;
        _devices = pageRows(devices.data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text('${_component?['name'] ?? 'Part'}')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (_error != null) Text(_error!),
                  if (_component?['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('${_component!['description']}'),
                    ),
                  Text('FITS THESE PHONES', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  if (_devices.isEmpty)
                    const ShopEmpty(title: 'No phones linked yet')
                  else
                    ..._devices.map(
                      (device) => ShopListTile(
                        title: '${device['brandName'] ?? ''} ${device['name'] ?? ''}'.trim(),
                        subtitle: '${device['modelCode'] ?? ''}',
                        onTap: () => context.push('/commons/devices/${device['id']}'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
