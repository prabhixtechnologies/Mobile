import 'package:flutter/material.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

String formatInr(num amount) => '₹${amount.toStringAsFixed(0)}';

String formatPaise(int paise) => formatInr(paise / 100);

/// Razorpay checkout through the native SDK.
///
/// A WebView could only finish card payments: netbanking, wallets and UPI apps open a
/// second window or an app intent, which a WebView drops without a word.
class PaySheet extends StatefulWidget {
  const PaySheet({
    super.key,
    required this.order,
    required this.description,
    required this.onPaid,
    required this.onCancel,
    this.onError,
  });

  final CheckoutOrder order;
  final String description;
  final ValueChanged<RazorpaySlip> onPaid;
  final VoidCallback onCancel;

  /// Razorpay reported a failure other than the person closing checkout.
  /// Falls back to [onCancel] when not given.
  final ValueChanged<String>? onError;

  @override
  State<PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<PaySheet> {
  final _razorpay = Razorpay();
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _open() {
    if (!mounted) return;
    final me = context.read<AppState>().me;
    final order = widget.order;
    _razorpay.open({
      'key': order.keyId,
      'amount': order.amount,
      'currency': order.currency,
      'name': 'MobiStack',
      'description': widget.description,
      'order_id': order.orderId,
      'prefill': {
        if (me != null && me.email.isNotEmpty) 'email': me.email,
      },
      // px-allow-literal: --px-accent, mobistack. Razorpay takes a hex string.
      'theme': {'color': '#b45309'},
    });
  }

  void _onSuccess(PaymentSuccessResponse response) {
    if (_handled) return;
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || paymentId == null || signature == null) {
      _fail('Razorpay did not return the payment details. Nothing was confirmed.');
      return;
    }
    _handled = true;
    widget.onPaid(
      RazorpaySlip(orderId: orderId, paymentId: paymentId, signature: signature),
    );
  }

  void _onFailure(PaymentFailureResponse response) {
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      _cancelOnce();
      return;
    }
    final message = response.code == Razorpay.NETWORK_ERROR
        ? 'No connection to Razorpay. Check the internet and try again.'
        : 'Payment did not go through. Nothing was charged. Try again.';
    _fail(message);
  }

  void _onWallet(ExternalWalletResponse response) {
    _fail('${response.walletName ?? 'That wallet'} is not supported here. Pick another way to pay.');
  }

  void _fail(String message) {
    if (_handled) return;
    _handled = true;
    final onError = widget.onError;
    if (onError != null) {
      onError(message);
    } else {
      widget.onCancel();
    }
  }

  void _cancelOnce() {
    if (_handled) return;
    _handled = true;
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Px.bg,
      appBar: AppBar(
        title: Text('Pay ${formatPaise(widget.order.amount)}'),
        leading: IconButton(
          tooltip: 'Cancel payment',
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancelOnce,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Px.accent),
            const SizedBox(height: 16),
            Text('Opening Razorpay…', style: TextStyle(color: Px.muted)),
            const SizedBox(height: 8),
            TextButton(onPressed: _open, child: const Text('Open again')),
          ],
        ),
      ),
    );
  }
}
