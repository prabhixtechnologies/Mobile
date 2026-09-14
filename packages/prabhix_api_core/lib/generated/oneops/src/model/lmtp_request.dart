//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lmtp_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LmtpRequest {
  /// Returns a new [LmtpRequest] instance.
  LmtpRequest({

    required  this.recipient,

    required  this.rawMimeBase64,
  });

  @JsonKey(
    
    name: r'recipient',
    required: true,
    includeIfNull: false,
  )


  final String recipient;



  @JsonKey(
    
    name: r'rawMimeBase64',
    required: true,
    includeIfNull: false,
  )


  final String rawMimeBase64;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LmtpRequest &&
      other.recipient == recipient &&
      other.rawMimeBase64 == rawMimeBase64;

    @override
    int get hashCode =>
        recipient.hashCode +
        rawMimeBase64.hashCode;

  factory LmtpRequest.fromJson(Map<String, dynamic> json) => _$LmtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LmtpRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

