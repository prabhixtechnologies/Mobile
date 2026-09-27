import 'package:flutter_test/flutter_test.dart';
import 'package:oneops/chat_deep_link.dart';

void main() {
  const uuid = '550e8400-e29b-41d4-a716-446655440000';

  test('accepts frozen prabhix scheme', () {
    expect(
      parseOneOpsChatDeepLink(Uri.parse('prabhix://chat/$uuid')),
      uuid,
    );
  });

  test('accepts verified https app link', () {
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse('https://oneops.prabhixtechnologies.com/chat/$uuid'),
      ),
      uuid,
    );
  });

  test('rejects wrong host', () {
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse('https://evil.example.com/chat/$uuid'),
      ),
      isNull,
    );
  });

  test('rejects extra path segments', () {
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse('https://oneops.prabhixtechnologies.com/chat/$uuid/extra'),
      ),
      isNull,
    );
  });

  test('rejects query smuggling on https links', () {
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse(
          'https://oneops.prabhixtechnologies.com/chat/$uuid?token=abc',
        ),
      ),
      isNull,
    );
  });

  test('rejects invalid ids', () {
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse('https://oneops.prabhixtechnologies.com/chat/../admin'),
      ),
      isNull,
    );
  });

  test('rejects prabhix host other than chat', () {
    expect(
      parseOneOpsChatDeepLink(Uri.parse('prabhix://notifications/$uuid')),
      isNull,
    );
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse('prabhix://evil.example.com/chat/$uuid'),
      ),
      isNull,
    );
  });

  test('rejects prabhix chat links with extra path segments', () {
    expect(
      parseOneOpsChatDeepLink(Uri.parse('prabhix://chat/$uuid/extra')),
      isNull,
    );
  });

  test('rejects https fragment on verified host', () {
    expect(
      parseOneOpsChatDeepLink(
        Uri.parse('https://oneops.prabhixtechnologies.com/chat/$uuid#x'),
      ),
      isNull,
    );
  });

  test('isVerifiedOneOpsAppLinkUri rejects userinfo', () {
    expect(
      isVerifiedOneOpsAppLinkUri(
        Uri.parse('https://user@oneops.prabhixtechnologies.com/chat/$uuid'),
      ),
      isFalse,
    );
  });
}
