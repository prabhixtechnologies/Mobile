//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ingest_ack.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IngestAck {
  /// Returns a new [IngestAck] instance.
  IngestAck({

     this.visitorKey,

     this.sessionId,
  });

  @JsonKey(
    
    name: r'visitorKey',
    required: false,
    includeIfNull: false,
  )


  final String? visitorKey;



  @JsonKey(
    
    name: r'sessionId',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IngestAck &&
      other.visitorKey == visitorKey &&
      other.sessionId == sessionId;

    @override
    int get hashCode =>
        visitorKey.hashCode +
        sessionId.hashCode;

  factory IngestAck.fromJson(Map<String, dynamic> json) => _$IngestAckFromJson(json);

  Map<String, dynamic> toJson() => _$IngestAckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

