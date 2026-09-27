/// Validates ids embedded in app / universal link paths before navigation.
bool isValidDeepLinkId(String? raw) {
  if (raw == null) return false;
  final value = raw.trim();
  if (value.isEmpty || value.length > 128) return false;
  if (value.contains('/') || value.contains('\\') || value.contains('..')) {
    return false;
  }
  final uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  if (uuid.hasMatch(value)) return true;
  final token = RegExp(r'^[A-Za-z0-9._-]{8,128}$');
  return token.hasMatch(value);
}

String? validatedDeepLinkId(String? raw) =>
    isValidDeepLinkId(raw) ? raw!.trim() : null;
