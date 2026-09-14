//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generic_ack.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenericAck {
  /// Returns a new [GenericAck] instance.
  GenericAck({

     this.message,
  });

  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GenericAck &&
      other.message == message;

    @override
    int get hashCode =>
        message.hashCode;

  factory GenericAck.fromJson(Map<String, dynamic> json) => _$GenericAckFromJson(json);

  Map<String, dynamic> toJson() => _$GenericAckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

