//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscribe_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubscribeRequest {
  /// Returns a new [SubscribeRequest] instance.
  SubscribeRequest({

    required  this.email,

     this.name,

     this.source_,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final String? source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SubscribeRequest &&
      other.email == email &&
      other.name == name &&
      other.source_ == source_;

    @override
    int get hashCode =>
        email.hashCode +
        name.hashCode +
        source_.hashCode;

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) => _$SubscribeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubscribeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

