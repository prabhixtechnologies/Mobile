import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';

void main() {
  test('AuthMe parses organizations and features', () {
    final me = AuthMe.fromJson({
      'userId': 'u1',
      'email': 'a@b.co',
      'displayName': 'Ada',
      'platformAdmin': true,
      'permissions': ['CHAT_READ'],
      'features': ['SALES', 'INVENTORY'],
      'organizations': [
        {'id': 'o1', 'name': 'Acme', 'slug': 'acme'},
      ],
    });
    expect(me.id, 'u1');
    expect(me.platformAdmin, isTrue);
    expect(me.permissions, contains('CHAT_READ'));
    expect(me.features, containsAll(['SALES', 'INVENTORY']));
    expect(me.organizations.single.name, 'Acme');
  });

  test('PlatformOverview parses nested Ops DTO', () {
    final overview = PlatformOverview.fromJson({
      'tenants': {
        'total': 3,
        'active': 2,
        'trial': 1,
        'suspended': 0,
        'cancelled': 0,
        'createdLast30Days': 1,
      },
      'accounts': {
        'total': 10,
        'active': 8,
        'platformAdmins': 2,
      },
      'queues': {
        'mailPending': 4,
        'mailFailed': 1,
        'activeSessions': 6,
      },
      'activity': {
        'errorsLast24h': 5,
        'securityEventsLast24h': 2,
      },
    });
    expect(overview.tenantCount, 3);
    expect(overview.tenants.active, 2);
    expect(overview.accounts.platformAdmins, 2);
    expect(overview.openMailBacklog, 4);
    expect(overview.eventsLast24h, 7);
  });
}
