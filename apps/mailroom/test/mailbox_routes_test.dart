import 'package:flutter_test/flutter_test.dart';
import 'package:mailroom/api/mail_api.dart';

void main() {
  test('folder threads use the cursor page route', () {
    expect(MailboxRoutes.folderThreadsPage, 'mailbox/folders/threads/page');
    expect(
      MailboxRoutes.folderPage(folderId: 'folder-1', cursor: 'abc', query: ' hello '),
      {'folderId': 'folder-1', 'limit': 50, 'cursor': 'abc', 'q': 'hello'},
    );
  });

  test('flags, replies and aliases are query parameters', () {
    expect(MailboxRoutes.flags, 'mailbox/threads/flags');
    expect(MailboxRoutes.reply, 'mail/threads/reply');
    expect(MailboxRoutes.aliases, 'mailbox/aliases');
    expect(MailboxRoutes.attachments, 'mailbox/attachments');
  });
}
