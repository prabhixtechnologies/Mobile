//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TeamView {
  /// Returns a new [TeamView] instance.
  TeamView({

     this.id,

     this.slug,

     this.name,

     this.description,

     this.leadUserId,

     this.memberCount,
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
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'leadUserId',
    required: false,
    includeIfNull: false,
  )


  final String? leadUserId;



  @JsonKey(
    
    name: r'memberCount',
    required: false,
    includeIfNull: false,
  )


  final int? memberCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TeamView &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.description == description &&
      other.leadUserId == leadUserId &&
      other.memberCount == memberCount;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        description.hashCode +
        leadUserId.hashCode +
        memberCount.hashCode;

  factory TeamView.fromJson(Map<String, dynamic> json) => _$TeamViewFromJson(json);

  Map<String, dynamic> toJson() => _$TeamViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

