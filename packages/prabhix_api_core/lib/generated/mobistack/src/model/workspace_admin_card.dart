//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_admin_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkspaceAdminCard {
  /// Returns a new [WorkspaceAdminCard] instance.
  WorkspaceAdminCard({

     this.id,

     this.name,

     this.city,

     this.active,

     this.members,

     this.extraScreens,

     this.screenSeats,
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
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'active',
    required: false,
    includeIfNull: false,
  )


  final bool? active;



  @JsonKey(
    
    name: r'members',
    required: false,
    includeIfNull: false,
  )


  final int? members;



  @JsonKey(
    
    name: r'extraScreens',
    required: false,
    includeIfNull: false,
  )


  final int? extraScreens;



  @JsonKey(
    
    name: r'screenSeats',
    required: false,
    includeIfNull: false,
  )


  final int? screenSeats;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkspaceAdminCard &&
      other.id == id &&
      other.name == name &&
      other.city == city &&
      other.active == active &&
      other.members == members &&
      other.extraScreens == extraScreens &&
      other.screenSeats == screenSeats;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        city.hashCode +
        active.hashCode +
        members.hashCode +
        extraScreens.hashCode +
        screenSeats.hashCode;

  factory WorkspaceAdminCard.fromJson(Map<String, dynamic> json) => _$WorkspaceAdminCardFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceAdminCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

