final _sensitive = RegExp(r'(password|token|secret|authorization)', caseSensitive: false);

const allowedEventNames = {
  'screen_view',
  'action',
  'auth_local',
  'error_ui',
  'perf_span',
};

bool isAllowedEventName(String name) => allowedEventNames.contains(name);

Map<String, Object?> scrubProps(Map<String, Object?>? props) {
  if (props == null || props.isEmpty) {
    return const {};
  }
  final out = <String, Object?>{};
  for (final entry in props.entries) {
    if (_sensitive.hasMatch(entry.key)) {
      continue;
    }
    final value = entry.value;
    if (value is String) {
      out[entry.key] = value.length > 512 ? value.substring(0, 512) : value;
    } else if (value == null || value is num || value is bool) {
      out[entry.key] = value;
    } else {
      out[entry.key] = value.toString();
    }
  }
  return out;
}
