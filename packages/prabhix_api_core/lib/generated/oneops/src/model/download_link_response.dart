//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'download_link_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DownloadLinkResponse {
  /// Returns a new [DownloadLinkResponse] instance.
  DownloadLinkResponse({

     this.downloadUrl,

     this.expiresAt,
  });

  @JsonKey(
    
    name: r'downloadUrl',
    required: false,
    includeIfNull: false,
  )


  final String? downloadUrl;



  @JsonKey(
    
    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DownloadLinkResponse &&
      other.downloadUrl == downloadUrl &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        downloadUrl.hashCode +
        expiresAt.hashCode;

  factory DownloadLinkResponse.fromJson(Map<String, dynamic> json) => _$DownloadLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadLinkResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

