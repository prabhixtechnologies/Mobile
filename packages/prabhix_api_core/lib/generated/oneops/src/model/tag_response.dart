//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TagResponse {
  /// Returns a new [TagResponse] instance.
  TagResponse({

     this.id,

     this.slug,

     this.name,

     this.colour,

     this.usageCount,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'colour',
    required: false,
    includeIfNull: false,
  )


  final String? colour;



  @JsonKey(
    
    name: r'usageCount',
    required: false,
    includeIfNull: false,
  )


  final int? usageCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TagResponse &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.colour == colour &&
      other.usageCount == usageCount;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        colour.hashCode +
        usageCount.hashCode;

  factory TagResponse.fromJson(Map<String, dynamic> json) => _$TagResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TagResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

