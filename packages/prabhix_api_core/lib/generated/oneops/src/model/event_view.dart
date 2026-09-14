//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventView {
  /// Returns a new [EventView] instance.
  EventView({

     this.id,

     this.name,

     this.properties,

     this.occurredAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'properties',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? properties;



  @JsonKey(
    
    name: r'occurredAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? occurredAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EventView &&
      other.id == id &&
      other.name == name &&
      other.properties == properties &&
      other.occurredAt == occurredAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        properties.hashCode +
        occurredAt.hashCode;

  factory EventView.fromJson(Map<String, dynamic> json) => _$EventViewFromJson(json);

  Map<String, dynamic> toJson() => _$EventViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

