import 'package:dio/dio.dart';

/// Server policy from `GET …/public/app-release?platform=ANDROID&build=N&app=…`.
class AppReleasePolicy {
  const AppReleasePolicy({
    required this.platform,
    required this.minNativeBuild,
    required this.latestNativeBuild,
    required this.forceNativeUpdate,
    required this.updateRequired,
    this.storeUrl,
    this.notes,
  });

  final String platform;
  final int minNativeBuild;
  final int latestNativeBuild;
  final bool forceNativeUpdate;
  final bool updateRequired;
  final String? storeUrl;
  final String? notes;

  factory AppReleasePolicy.fromJson(Map<String, dynamic> json) {
    return AppReleasePolicy(
      platform: '${json['platform'] ?? 'ANDROID'}',
      minNativeBuild: _int(json['minNativeBuild']),
      latestNativeBuild: _int(json['latestNativeBuild']),
      forceNativeUpdate: json['forceNativeUpdate'] == true,
      updateRequired: json['updateRequired'] == true,
      storeUrl: json['storeUrl']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

/// Query parameters for a public app-release request.
Map<String, dynamic> buildAppReleaseQuery({
  required int nativeBuild,
  String platform = 'ANDROID',
  String? appId,
  bool includeAppId = true,
}) {
  final query = <String, dynamic>{
    'platform': platform,
    'build': nativeBuild,
  };
  if (includeAppId && appId != null && appId.trim().isNotEmpty) {
    query['app'] = appId.trim();
  }
  return query;
}

/// Fetches release policy without auth. Returns null when the endpoint is absent.
Future<AppReleasePolicy?> fetchAppReleasePolicy({
  required String publicApiBase,
  required int nativeBuild,
  String platform = 'ANDROID',
  String? appId,
  bool includeAppId = true,
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  final base = publicApiBase.replaceAll(RegExp(r'/+$'), '');
  try {
    final res = await client.get<dynamic>(
      '$base/public/app-release',
      queryParameters: buildAppReleaseQuery(
        nativeBuild: nativeBuild,
        platform: platform,
        appId: appId,
        includeAppId: includeAppId,
      ),
      options: Options(
        headers: const {'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
      ),
    );
    final data = res.data;
    if (data is! Map) return null;
    return AppReleasePolicy.fromJson(Map<String, dynamic>.from(data));
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    rethrow;
  }
}
