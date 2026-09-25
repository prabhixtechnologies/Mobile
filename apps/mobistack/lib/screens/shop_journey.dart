import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/pay_sheet.dart';

class ShopStartScreen extends StatelessWidget {
  const ShopStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Gate(
      title: 'Your shop',
      body: 'Create your own counter, or join a shop that already exists.',
      children: [
        PxPrimaryButton(
          label: 'Create shop',
          icon: Icons.storefront_outlined,
          onPressed: () => context.push('/shop/new'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => context.push('/shop/join'),
          child: const Text('Join a shop'),
        ),
        TextButton(
          onPressed: () => context.push('/shop/invite'),
          child: const Text('I have an invite'),
        ),
        TextButton(
          onPressed: () => context.read<AppState>().signOut(),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'A shop needs a name.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<AppState>().createShop(name: name, city: _city.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    return _Gate(
      title: 'Create shop',
      body: 'This does not ask for payment. You join the union on the next screen.',
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Shop name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _city,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'City'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Px.danger)),
        ],
        const SizedBox(height: 18),
        PxPrimaryButton(
          label: _busy ? 'Creating…' : 'Create shop',
          busy: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ],
    );
  }
}

class JoinShopScreen extends StatelessWidget {
  const JoinShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CodeJoin(
      title: 'Join a shop',
      body: 'Enter the code from that shop. A real code opens payment of ₹50.',
      group: false,
    );
  }
}

class JoinUnionScreen extends StatelessWidget {
  const JoinUnionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CodeJoin(
      title: 'Join the union',
      body: 'Enter the code for Bihar mobile union. A matching code opens payment of ₹50.',
      group: true,
    );
  }
}

class InviteShopScreen extends StatefulWidget {
  const InviteShopScreen({super.key});

  @override
  State<InviteShopScreen> createState() => _InviteShopScreenState();
}

class _InviteShopScreenState extends State<InviteShopScreen> {
  final _token = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _token.text.trim();
    if (token.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<AppState>().acceptShopInvite(token);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final ready = _token.text.trim().isNotEmpty && !_busy;
    return _Gate(
      title: 'Invite',
      body: 'An owner invite is free. Paste the token from the email.',
      children: [
        TextField(
          controller: _token,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Invite token'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Px.danger)),
        ],
        const SizedBox(height: 18),
        PxPrimaryButton(
          label: _busy ? 'Checking…' : 'Accept invite',
          busy: _busy,
          onPressed: ready ? _submit : null,
        ),
      ],
    );
  }
}

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key, required this.union});

  final bool union;

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  String? _error;
  bool _busy = false;

  Future<void> _cancel() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<AppState>().cancelWaitingJoin();
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final title = context.watch<AppState>().waitingTitle;
    final who = widget.union ? 'a union admin' : 'the shop owner';
    return _Gate(
      title: 'Waiting',
      body: title == null
          ? 'Payment is done. $who still has to approve.'
          : 'Payment is done for $title. $who still has to approve.',
      children: [
        if (_error != null) ...[
          Text(_error!, style: TextStyle(color: Px.danger)),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          onPressed: _busy ? null : _cancel,
          child: Text(_busy ? 'Cancelling…' : 'Cancel request'),
        ),
      ],
    );
  }
}

class OutsideUnionScreen extends StatelessWidget {
  const OutsideUnionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AppState>().waitingTitle ?? 'This shop';
    return _Gate(
      title: name,
      body: 'You are in this shop. It is not in Bihar mobile union yet, so compatibility stays closed until a union admin adds it.',
      children: [
        TextButton(
          onPressed: () => context.read<AppState>().signOut(),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _CodeJoin extends StatefulWidget {
  const _CodeJoin({required this.title, required this.body, required this.group});

  final String title;
  final String body;
  final bool group;

  @override
  State<_CodeJoin> createState() => _CodeJoinState();
}

class _CodeJoinState extends State<_CodeJoin> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;
  CheckoutOrder? _pay;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = context.read<AppState>().api;
    try {
      final order = widget.group
          ? await api.joinGroupCheckout(code)
          : await api.joinShopCheckout(code);
      if (!mounted) return;
      if (order.alreadyPaid || !order.needsRazorpay) {
        await _finish(order, null);
        return;
      }
      setState(() {
        _pay = order;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _busy = false;
      });
      if ('$e'.contains('already')) {
        await context.read<AppState>().refreshJourney();
      }
    }
  }

  Future<void> _finish(CheckoutOrder order, RazorpaySlip? slip) async {
    final code = _code.text.trim();
    final state = context.read<AppState>();
    try {
      if (widget.group) {
        await state.api.joinGroupComplete(
          joinCode: code,
          orderId: slip == null ? order.id : null,
          slip: slip,
        );
      } else {
        await state.api.joinShopComplete(
          joinCode: code,
          orderId: slip == null ? order.id : null,
          slip: slip,
        );
      }
      await state.refreshJourney();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _code.text.trim().isNotEmpty && !_busy && _pay == null;
    return Stack(
      children: [
        _Gate(
          title: widget.title,
          body: widget.body,
          children: [
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Px.danger)),
            ],
            const SizedBox(height: 18),
            PxPrimaryButton(
              label: _busy ? 'Checking…' : 'Continue',
              busy: _busy,
              onPressed: ready ? _submit : null,
            ),
          ],
        ),
        if (_pay != null)
          PaySheet(
            order: _pay!,
            description: widget.group ? 'Join the union' : 'Join shop',
            onCancel: () => setState(() => _pay = null),
            onPaid: (slip) async {
              final order = _pay;
              setState(() {
                _pay = null;
                _busy = true;
              });
              if (order != null) await _finish(order, slip);
            },
          ),
      ],
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate({required this.title, required this.body, required this.children});

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Atmosphere(
      intense: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            children: [
              const BrandMark(),
              const SizedBox(height: 28),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(body, style: TextStyle(color: Px.muted, fontSize: 16, height: 1.4)),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
