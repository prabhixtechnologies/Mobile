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
  bool _refreshing = false;
  String? _error;

  String get _cacheKey => 'component.${widget.componentId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _applyCache(AppState state) async {
    final cached = await state.sync.commonsPage(_cacheKey);
    if (!mounted || cached == null) return;
    final component = cached['component'];
    setState(() {
      _component = component is Map ? Map<String, dynamic>.from(component) : _component;
      _devices = pageRows(cached['devices']);
      _loading = false;
    });
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    await _applyCache(state);
    if (!mounted) return;
    if (!state.online) {
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = _component == null ? 'Offline · this part is not cached yet' : null;
      });
      return;
    }
    setState(() {
      _refreshing = true;
      _error = null;
      if (_component == null) _loading = true;
    });
    try {
      final results = await Future.wait([
        state.api.dio.get<dynamic>('commons/components/${widget.componentId}'),
        state.api.dio.get<dynamic>('commons/components/${widget.componentId}/devices'),
      ]);
      final component = results[0].data is Map
          ? Map<String, dynamic>.from(results[0].data as Map)
          : null;
      final devices = pageRows(results[1].data);
      await state.sync.saveCommonsPage(_cacheKey, {
        'component': component,
        'devices': devices,
      });
      if (!mounted) return;
      setState(() {
        _component = component;
        _devices = devices;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _component == null ? '$e' : null;
        _loading = false;
        _refreshing = false;
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
                  if (_refreshing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
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
