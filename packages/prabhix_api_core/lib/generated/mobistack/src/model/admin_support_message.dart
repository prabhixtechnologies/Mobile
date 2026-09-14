//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_support_message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminSupportMessage {
  /// Returns a new [AdminSupportMessage] instance.
  AdminSupportMessage({

     this.id,

     this.authorType,

     this.body,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'authorType',
    required: false,
    includeIfNull: false,
  )


  final String? authorType;



  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminSupportMessage &&
      other.id == id &&
      other.authorType == authorType &&
      other.body == body;

    @override
    int get hashCode =>
        id.hashCode +
        authorType.hashCode +
        body.hashCode;

  factory AdminSupportMessage.fromJson(Map<String, dynamic> json) => _$AdminSupportMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

