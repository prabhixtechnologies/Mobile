//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lmtp_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LmtpResponse {
  /// Returns a new [LmtpResponse] instance.
  LmtpResponse({

     this.inboundRawId,
  });

  @JsonKey(
    
    name: r'inboundRawId',
    required: false,
    includeIfNull: false,
  )


  final String? inboundRawId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LmtpResponse &&
      other.inboundRawId == inboundRawId;

    @override
    int get hashCode =>
        inboundRawId.hashCode;

  factory LmtpResponse.fromJson(Map<String, dynamic> json) => _$LmtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LmtpResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

