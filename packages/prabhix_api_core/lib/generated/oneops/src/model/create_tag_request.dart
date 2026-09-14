//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_tag_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateTagRequest {
  /// Returns a new [CreateTagRequest] instance.
  CreateTagRequest({

    required  this.name,

     this.slug,

     this.colour,

     this.description,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'colour',
    required: false,
    includeIfNull: false,
  )


  final String? colour;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateTagRequest &&
      other.name == name &&
      other.slug == slug &&
      other.colour == colour &&
      other.description == description;

    @override
    int get hashCode =>
        name.hashCode +
        slug.hashCode +
        colour.hashCode +
        description.hashCode;

  factory CreateTagRequest.fromJson(Map<String, dynamic> json) => _$CreateTagRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTagRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

