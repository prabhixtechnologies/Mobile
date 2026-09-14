//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ack_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AckResponse {
  /// Returns a new [AckResponse] instance.
  AckResponse({

     this.message,
  });

  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AckResponse &&
      other.message == message;

    @override
    int get hashCode =>
        message.hashCode;

  factory AckResponse.fromJson(Map<String, dynamic> json) => _$AckResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AckResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

