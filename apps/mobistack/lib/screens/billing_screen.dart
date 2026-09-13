import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Razorpay checkout placeholder hosted in a WebView.
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => loading = false);
          },
        ),
      )
      ..loadHtmlString('''
<!DOCTYPE html>
<html>
<head><meta name="viewport" content="width=device-width, initial-scale=1"/>
<style>body{font-family:system-ui;padding:24px;background:#f7f7f7} .card{background:#fff;border-radius:12px;padding:20px}</style>
</head>
<body>
  <div class="card">
    <h2>MobiStack billing</h2>
    <p>Razorpay checkout placeholder. Wire this WebView to your hosted payment page.</p>
    <button onclick="alert('Razorpay placeholder')">Pay with Razorpay</button>
  </div>
</body>
</html>
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
