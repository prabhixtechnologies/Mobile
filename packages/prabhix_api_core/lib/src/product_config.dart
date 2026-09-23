class ProductConfig {
  const ProductConfig({
    required this.apiBaseUrl,
    required this.deviceHeader,
    this.orgHeaderName = 'X-Prabhix-Org',
    this.deviceHeaderName = 'X-Prabhix-Device',
    this.selectPathTemplate = 'organizations/{id}/select',
  });

  /// e.g. `https://api.prabhixtechnologies.com/api/v1`
  final String apiBaseUrl;
  final String deviceHeader;
  final String orgHeaderName;
  final String deviceHeaderName;

  /// Relative path for pinning the active org or workspace. `{id}` is replaced.
  final String selectPathTemplate;

  String selectPath(String id) => selectPathTemplate.replaceAll('{id}', id);

  factory ProductConfig.platform({
    required String apiBaseUrl,
    required String deviceHeader,
  }) {
    return ProductConfig(
      apiBaseUrl: apiBaseUrl.replaceAll(RegExp(r'/+$'), ''),
      deviceHeader: deviceHeader,
    );
  }

  factory ProductConfig.mobistack({required String apiBaseUrl}) {
    return ProductConfig(
      apiBaseUrl: apiBaseUrl.replaceAll(RegExp(r'/+$'), ''),
      deviceHeader: 'mobile-flutter',
      orgHeaderName: 'X-MobiStack-Workspace',
      deviceHeaderName: 'X-MobiStack-Device',
      selectPathTemplate: 'workspaces/{id}/select',
    );
  }
}
