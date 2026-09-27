import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prabhix_ui/prabhix_ui.dart';
import 'package:provider/provider.dart';

import '../models/inbox_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return;
      final state = context.read<AppState>();
      if (state.orders.isEmpty) {
        state.refreshOrders();
      }
    });
  }

  static const _fulfilWarning =
      'This releases the order and notifies the customer. It cannot be reversed here.';

  /// Fulfils an order once the user has confirmed.
  ///
  /// Fulfilment releases the goods and notifies the customer, so it is not something to
  /// take back. It used to fire from a single tap on a text button in a scrolling list.
  Future<void> _fulfil(BuildContext context, AppState state, OrderRow order) async {
    final ok = await confirmDestructive(
      context,
      title: 'Fulfil ${order.label}?',
      message: _fulfilWarning,
      confirmLabel: 'Fulfil',
      icon: Icons.local_shipping_outlined,
    );
    if (!ok || !context.mounted) return;
    await _fulfilConfirmed(context, state, order);
  }

  /// The half of [_fulfil] after the user has said yes.
  ///
  /// Split out because [invokePxAction] runs the confirmation itself for a
  /// [PxRisk.confirm] action, and asking twice for one tap reads as a bug.
  Future<void> _fulfilConfirmed(
    BuildContext context,
    AppState state,
    OrderRow order,
  ) async {
    await state.fulfillOrder(order.id);
    if (!context.mounted) return;
    showOutcome(context, success: '${order.label} fulfilled');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Atmosphere(
        child: RefreshIndicator(
          color: Px.accent,
          onRefresh: () => state.refreshOrders(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (state.orders.isEmpty)
                PxEmpty(
                  title: 'No orders yet',
                  message: 'Orders placed through the storefront land here as soon as they '
                      'are paid for.',
                  icon: Icons.receipt_long_outlined,
                  actionLabel: 'Refresh',
                  onAction: state.refreshOrders,
                )
              else
                ...state.orders.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PxActionable(
                      title: o.label,
                      subtitle: [o.status, o.total].whereType<String>().join(' · '),
                      actions: [
                        PxAction(
                          label: 'Fulfil',
                          icon: Icons.local_shipping_outlined,
                          risk: PxRisk.confirm,
                          confirmTitle: 'Fulfil ${o.label}?',
                          confirmMessage: _fulfilWarning,
                          onInvoke: () => _fulfilConfirmed(context, state, o),
                        ),
                        PxAction(
                          label: 'Copy order reference',
                          icon: Icons.copy_rounded,
                          risk: PxRisk.safe,
                          onInvoke: () {
                            Clipboard.setData(ClipboardData(text: o.label));
                            showOutcome(context, success: 'Reference copied');
                          },
                        ),
                      ],
                      child: ListTile(
                        title: Text(o.label),
                        subtitle:
                            Text([o.status, o.total].whereType<String>().join(' · ')),
                        trailing: TextButton(
                          onPressed: () => _fulfil(context, state, o),
                          child: const Text('Fulfil'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
