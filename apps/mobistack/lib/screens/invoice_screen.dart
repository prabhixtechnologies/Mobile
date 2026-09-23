import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../state/app_state.dart';
import '../widgets/shop_ui.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.saleId});

  final String saleId;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  WebViewController? _web;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final html = await context.read<AppState>().invoiceHtml(widget.saleId);
      if (!mounted) return;
      final controller = WebViewController()..loadHtmlString(html);
      setState(() => _web = controller);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      title: 'Invoice',
      child: _error != null
          ? ShopEmpty(title: 'Invoice unavailable', subtitle: _error, icon: Icons.receipt_long_outlined)
          : _web == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _web!),
    );
  }
}
