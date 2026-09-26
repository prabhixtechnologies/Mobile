import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/shop_models.dart';
import '../services/counter_payloads.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _paused = false;

  bool get _testing => Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    if (!_testing) _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _resume() async {
    _paused = false;
    try {
      await _controller?.start();
    } catch (_) {}
  }

  Future<void> _onCode(String code) async {
    if (_paused || !mounted) return;
    _paused = true;
    try {
      await _controller?.stop();
    } catch (_) {}
    if (!mounted) return;
    final state = context.read<AppState>();
    final match = state.matchCode(code);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Px.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheet) => _ScanSheet(code: code, match: match),
    );
    if (mounted) {
      context.read<AppState>().setLastScan(code);
      await _resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final billCount = context.watch<AppState>().bill.lines.fold<int>(0, (n, line) => n + line.quantity);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan barcode'),
        actions: [
          if (billCount > 0)
            TextButton(
              onPressed: () => context.go('/sales'),
              child: Text('Bill $billCount'),
            ),
        ],
      ),
      body: _testing
          ? const Center(child: Text('Point at a barcode'))
          : Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final code = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
                    if (code == null || code.isEmpty) return;
                    _onCode(code);
                  },
                  onDetectError: (_, __) {},
                ),
              ],
            ),
    );
  }
}

class _ScanSheet extends StatefulWidget {
  const _ScanSheet({required this.code, required this.match});

  final String code;
  final CachedVariant? match;

  @override
  State<_ScanSheet> createState() => _ScanSheetState();
}

class _ScanSheetState extends State<_ScanSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController(text: '1');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottom),
      child: widget.match == null ? _registerForm(context) : _known(context, widget.match!),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Px.line,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Widget _codeChip(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Px.bgAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: Px.ink,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _known(BuildContext context, CachedVariant variant) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _handle(),
        Text(variant.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          '${variant.sku} · ${variant.availableQty} in stock',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        Text(
          variant.retailPrice.toStringAsFixed(2),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Px.accent),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () {
            context.read<AppState>().addToBill(variant);
            Navigator.pop(context);
          },
          child: const Text('Sell'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _receive(context, variant),
          child: const Text('Add stock'),
        ),
        TextButton(
          onPressed: () => _showFits(context, variant),
          child: const Text('Which phones'),
        ),
      ],
    );
  }

  Widget _registerForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _handle(),
        Text('Register part', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'This code is not in the shop yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _codeChip(widget.code),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Retail price'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qty,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Opening quantity'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _saving ? null : () => _save(context),
          child: Text(_saving ? 'Saving…' : 'Save part'),
        ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _saving = true);
    final error = await context.read<AppState>().createPart(
          name: _name.text.trim().isEmpty ? widget.code : _name.text.trim(),
          sku: widget.code,
          barcode: widget.code,
          price: double.tryParse(_price.text) ?? 0,
          qty: int.tryParse(_qty.text) ?? 0,
        );
    if (!context.mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Part added')),
    );
    if (error == null) Navigator.pop(context);
  }

  Future<void> _receive(BuildContext context, CachedVariant variant) async {
    final qty = await _askQty(context, 'Add stock');
    if (qty == null || !context.mounted) return;
    final result = await context.read<AppState>().submitOp(
      type: 'RECEIVE',
      body: {
        'receive': {'variantId': variant.id, 'quantity': qty},
      },
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(counterMessage(result, synced: 'Stock received', queued: 'Receive queued'))),
    );
    Navigator.pop(context);
  }

  Future<void> _showFits(BuildContext context, CachedVariant variant) async {
    final phones = await _phonesFor(context, variant);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Px.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Fits', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(phones.isEmpty ? 'No fitment saved for this part.' : phones.join('\n')),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<String>> _phonesFor(BuildContext context, CachedVariant variant) async {
  final state = context.read<AppState>();
  if (!state.online) return const ['Connect to look up fitment'];
  try {
    final variantRes = await state.api.dio.get<dynamic>(
      'variants',
      queryParameters: {'id': variant.id},
    );
    final data = variantRes.data;
    final componentId = data is Map ? '${data['catalogComponentId'] ?? ''}' : '';
    if (componentId.isEmpty) return const [];
    final fits = await state.api.dio.get<dynamic>(
      'commons/components/devices',
      queryParameters: {'componentId': componentId},
    );
    final rows = fits.data;
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map) '${row['name'] ?? row['deviceName'] ?? row}',
    ];
  } catch (e) {
    return ['$e'];
  }
}

Future<int?> _askQty(BuildContext context, String title) async {
  final field = TextEditingController(text: '1');
  final qty = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: field,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(labelText: 'Quantity'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, int.tryParse(field.text) ?? 0),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  field.dispose();
  if (qty == null || qty < 1) return null;
  return qty;
}
