const successInterval = Duration(hours: 24);
const failureRetry = Duration(hours: 1);

class FlushPolicyState {
  const FlushPolicyState({
    this.lastSuccessAt,
    this.lastFailureAt,
    this.lastAttemptAt,
  });

  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final DateTime? lastAttemptAt;
}

/// 24h after success, or 1h after failure. First run always flushes.
bool shouldFlush(FlushPolicyState state, DateTime now) {
  if (state.lastAttemptAt == null) {
    return true;
  }

  final successMs = state.lastSuccessAt?.millisecondsSinceEpoch ?? -1;
  final failureMs = state.lastFailureAt?.millisecondsSinceEpoch ?? -1;

  if (successMs >= failureMs) {
    if (state.lastSuccessAt == null) {
      return now.difference(state.lastAttemptAt!) >= failureRetry;
    }
    return now.difference(state.lastSuccessAt!) >= successInterval;
  }

  return now.difference(state.lastFailureAt ?? state.lastAttemptAt!) >= failureRetry;
}
