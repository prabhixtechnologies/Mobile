//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sse_emitter.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SseEmitter {
  /// Returns a new [SseEmitter] instance.
  SseEmitter({

     this.timeout,
  });

  @JsonKey(
    
    name: r'timeout',
    required: false,
    includeIfNull: false,
  )


  final int? timeout;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SseEmitter &&
      other.timeout == timeout;

    @override
    int get hashCode =>
        timeout.hashCode;

  factory SseEmitter.fromJson(Map<String, dynamic> json) => _$SseEmitterFromJson(json);

  Map<String, dynamic> toJson() => _$SseEmitterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

