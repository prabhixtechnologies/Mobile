//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_event_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderEventView {
  /// Returns a new [OrderEventView] instance.
  OrderEventView({

     this.eventType,

     this.message,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'eventType',
    required: false,
    includeIfNull: false,
  )


  final String? eventType;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderEventView &&
      other.eventType == eventType &&
      other.message == message &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        eventType.hashCode +
        message.hashCode +
        createdAt.hashCode;

  factory OrderEventView.fromJson(Map<String, dynamic> json) => _$OrderEventViewFromJson(json);

  Map<String, dynamic> toJson() => _$OrderEventViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

