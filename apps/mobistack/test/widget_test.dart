import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobistack/config.dart';
import 'package:mobistack/models/shop_models.dart';
import 'package:mobistack/screens/barcode_scanner_screen.dart';
import 'package:mobistack/screens/compatibility_screen.dart';
import 'package:mobistack/screens/home_screen.dart';
import 'package:mobistack/screens/inbox_screen.dart';
import 'package:mobistack/screens/inventory_screen.dart';
import 'package:mobistack/screens/login_screen.dart';
import 'package:mobistack/screens/members_screen.dart';
import 'package:mobistack/screens/movements_screen.dart';
import 'package:mobistack/screens/private_notes_screen.dart';
import 'package:mobistack/screens/profile_screen.dart';
import 'package:mobistack/screens/purchases_screen.dart';
import 'package:mobistack/screens/repairs_screen.dart';
import 'package:mobistack/screens/sales_screen.dart';
import 'package:mobistack/screens/settings_screen.dart';
import 'package:mobistack/services/counter_payloads.dart';
import 'package:mobistack/services/open_bill.dart';
import 'package:mobistack/screens/suppliers_screen.dart';
import 'package:mobistack/state/app_state.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';

AppState readyState() {
  final state = AppState(config: AppConfig.fromEnvironment());
  state.phase = AuthPhase.ready;
  state.me = AuthMe(
    id: 'u1',
    email: 'shop@prabhix.test',
    displayName: 'Shop floor',
    features: {
      'INVENTORY',
      'SALES',
      'REPAIRS',
      'PURCHASES',
      'MEMBERS',
      'SUPPLIERS',
    },
  );
  state.dashboard = CachedDashboard(todaySales: 1200, todayTransactions: 4);
  state.variants = [
    CachedVariant(
      id: 'v1',
      productName: 'Screen',
      variantName: 'OLED',
      sku: 'SCR-1',
      availableQty: 3,
    ),
  ];
  state.repairs = [
    CachedRepair(id: 'r1', jobNumber: 'JOB-9', status: 'OPEN'),
  ];
  state.commonsDevices = [
    CachedDevice(id: 'd1', name: 'Pixel 8', brandName: 'Google'),
  ];
  state.pendingOps = 2;
  return state;
}

Widget wrap(AppState state, Widget child) {
  return ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('login asks for Identity', (tester) async {
    final state = AppState(config: AppConfig.fromEnvironment());
    state.phase = AuthPhase.signedOut;
    await tester.pumpWidget(wrap(state, const LoginScreen()));
    await tester.pump();
    expect(find.text('Login with Prabhix Identity'), findsOneWidget);
    state.dispose();
  });

  testWidgets('home and offline sync strip', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const HomeScreen()));
    await tester.pump();
    expect(find.text('MobiStack'), findsOneWidget);
    expect(find.textContaining('queued'), findsOneWidget);
    state.dispose();
  });

  testWidgets('fitment catalog', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const CompatibilityScreen()));
    await tester.pump();
    expect(find.text('Parts'), findsOneWidget);
    expect(find.text('Saved spares'), findsOneWidget);
    expect(find.text('Display'), findsOneWidget);
    expect(find.text('Battery'), findsOneWidget);
    state.dispose();
  });

  testWidgets('inventory stock', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const InventoryScreen()));
    await tester.pump();
    expect(find.text('Stock'), findsOneWidget);
    expect(find.textContaining('Screen'), findsWidgets);
    state.dispose();
  });

  testWidgets('sales', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const SalesScreen()));
    await tester.pump();
    expect(find.text('Sales'), findsOneWidget);
    state.dispose();
  });

  testWidgets('repairs', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const RepairsScreen()));
    await tester.pump();
    expect(find.text('Repairs'), findsOneWidget);
    expect(find.textContaining('JOB-9'), findsWidgets);
    state.dispose();
  });

  testWidgets('purchases suppliers members movements inbox', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const PurchasesScreen()));
    await tester.pump();
    expect(find.text('Purchases'), findsOneWidget);

    await tester.pumpWidget(wrap(state, const SuppliersScreen()));
    await tester.pump();
    expect(find.text('Suppliers'), findsOneWidget);

    await tester.pumpWidget(wrap(state, const MembersScreen()));
    await tester.pump();
    expect(find.text('Members'), findsOneWidget);

    await tester.pumpWidget(wrap(state, const MovementsScreen()));
    await tester.pump();
    expect(find.text('Stock movements'), findsOneWidget);

    await tester.pumpWidget(wrap(state, const InboxScreen()));
    await tester.pump();
    expect(find.text('Inbox'), findsOneWidget);
    state.dispose();
  });

  testWidgets('private fitment notes', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const PrivateNotesScreen()));
    await tester.pump();
    expect(find.text('Private fitment notes'), findsOneWidget);
    state.dispose();
  });

  testWidgets('barcode scanner', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const BarcodeScannerScreen()));
    await tester.pump();
    expect(find.text('Scan barcode'), findsOneWidget);
    expect(find.text('Point at a barcode'), findsOneWidget);
    state.dispose();
  });

  testWidgets('settings and profile open Identity account', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const SettingsScreen()));
    await tester.pump();
    expect(find.text('Manage account'), findsOneWidget);

    await tester.pumpWidget(wrap(state, const ProfileScreen()));
    await tester.pump();
    expect(find.text('Manage account'), findsOneWidget);
    expect(find.text('shop@prabhix.test'), findsOneWidget);
    state.dispose();
  });

  test('mobistack select path is the workspace endpoint', () {
    final mobistack = ProductConfig.mobistack(
      apiBaseUrl: 'https://mobistack.prabhixtechnologies.com/api/v1',
    );
    expect(
      mobistack.selectPath('ff7cce39-e964-4973-9e98-8e219e44d708'),
      'workspaces/ff7cce39-e964-4973-9e98-8e219e44d708/select',
    );
    final platform = ProductConfig.platform(
      apiBaseUrl: 'https://api.prabhixtechnologies.com/api/v1',
      deviceHeader: 'oneops',
    );
    expect(platform.selectPath('org-1'), 'organizations/org-1/select');
  });

  test('open bill stacks the same part and pays cash', () {
    final bill = OpenBill();
    final variant = CachedVariant(
      id: 'v1',
      productName: 'Screen',
      variantName: 'OLED',
      sku: 'SCR-1',
      retailPrice: 100,
    );
    bill.add(variant);
    bill.add(variant);
    expect(bill.lines.single.quantity, 2);
    expect(bill.total, 200);
    final body = bill.toSaleBody();
    expect((body['items'] as List).single['quantity'], 2);
    expect((body['payments'] as List).single['method'], 'CASH');
    expect((body['payments'] as List).single['amount'], 200);
  });

  test('sale payload is a cash sale with one line', () {
    final body = salePayload(CachedVariant(
      id: 'v1',
      productName: 'Screen',
      variantName: 'OLED',
      sku: 'SCR-1',
      retailPrice: 499,
    ));
    final items = body['items'] as List;
    expect(items.single['variantId'], 'v1');
    expect(items.single['quantity'], 1);
    expect(items.single['unitPrice'], 499);
    final payments = body['payments'] as List;
    expect(payments.single['method'], 'CASH');
    expect(payments.single['amount'], 499);
  });
}
