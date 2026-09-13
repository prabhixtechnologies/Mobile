import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/prabhix_theme.dart';

String formatInr(num amount) => '₹${amount.toStringAsFixed(0)}';

String formatPaise(int paise) => formatInr(paise / 100);

/// Razorpay Standard Checkout inside a WebView (parity with Expo PaySheet).
class PaySheet extends StatefulWidget {
  const PaySheet({
    super.key,
    required this.order,
    required this.description,
    required this.onPaid,
    required this.onCancel,
  });

  final CheckoutOrder order;
  final String description;
  final ValueChanged<RazorpaySlip> onPaid;
  final VoidCallback onCancel;

  @override
  State<PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<PaySheet> {
  late final WebViewController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PrabhixPay',
        onMessageReceived: (message) {
          if (_handled) return;
          try {
            final payload = jsonDecode(message.message);
            if (payload is! Map) {
              _cancelOnce();
              return;
            }
            if (payload['cancelled'] == true || payload['ok'] != true) {
              _cancelOnce();
              return;
            }
            final orderId = payload['razorpay_order_id']?.toString();
            final paymentId = payload['razorpay_payment_id']?.toString();
            final signature = payload['razorpay_signature']?.toString();
            if (orderId == null || paymentId == null || signature == null) {
              _cancelOnce();
              return;
            }
            _handled = true;
            widget.onPaid(
              RazorpaySlip(
                orderId: orderId,
                paymentId: paymentId,
                signature: signature,
              ),
            );
          } catch (_) {
            _cancelOnce();
          }
        },
      )
      ..loadHtmlString(
        _checkoutHtml(widget.order, widget.description),
        baseUrl: 'https://mobistack.prabhixtechnologies.com',
      );
  }

  void _cancelOnce() {
    if (_handled) return;
    _handled = true;
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Px.ink,
      appBar: AppBar(
        backgroundColor: Px.ink,
        foregroundColor: Px.accentInk,
        title: Text('Pay ${formatPaise(widget.order.amount)}'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancelOnce,
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

String _checkoutHtml(CheckoutOrder order, String description) {
  String safe(String? value) =>
      (value ?? '').replaceAll(RegExp(r'''[<>\\'"]'''), '');
  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
  </head>
  <body style="background:#0C1524;color:#F0FDFA;font-family:sans-serif;padding:24px">
    <p>Opening Razorpay…</p>
    <script>
      var options = {
        key: "${safe(order.keyId)}",
        amount: ${order.amount},
        currency: "${safe(order.currency)}",
        name: "MobiStack",
        description: "${safe(description)}",
        order_id: "${safe(order.orderId)}",
        theme: { color: "#0E7490" },
        handler: function (response) {
          PrabhixPay.postMessage(JSON.stringify({
            ok: true,
            razorpay_order_id: response.razorpay_order_id,
            razorpay_payment_id: response.razorpay_payment_id,
            razorpay_signature: response.razorpay_signature
          }));
        },
        modal: {
          ondismiss: function () {
            PrabhixPay.postMessage(JSON.stringify({ ok: false, cancelled: true }));
          }
        }
      };
      var rzp = new Razorpay(options);
      rzp.on("payment.failed", function (resp) {
        PrabhixPay.postMessage(JSON.stringify({
          ok: false,
          error: (resp && resp.error && resp.error.description) || "Payment failed"
        }));
      });
      rzp.open();
    </script>
  </body>
</html>
''';
}
