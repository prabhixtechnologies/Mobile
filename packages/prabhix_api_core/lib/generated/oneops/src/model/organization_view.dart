//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrganizationView {
  /// Returns a new [OrganizationView] instance.
  OrganizationView({

     this.id,

     this.name,

     this.slug,

     this.status,

     this.memberCount,

     this.seatLimit,

     this.trialEndsAt,

     this.timezone,

     this.locale,

     this.currency,

     this.createdAt,
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
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'memberCount',
    required: false,
    includeIfNull: false,
  )


  final int? memberCount;



  @JsonKey(
    
    name: r'seatLimit',
    required: false,
    includeIfNull: false,
  )


  final int? seatLimit;



  @JsonKey(
    
    name: r'trialEndsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? trialEndsAt;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrganizationView &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.status == status &&
      other.memberCount == memberCount &&
      other.seatLimit == seatLimit &&
      other.trialEndsAt == trialEndsAt &&
      other.timezone == timezone &&
      other.locale == locale &&
      other.currency == currency &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        slug.hashCode +
        status.hashCode +
        memberCount.hashCode +
        seatLimit.hashCode +
        trialEndsAt.hashCode +
        timezone.hashCode +
        locale.hashCode +
        currency.hashCode +
        createdAt.hashCode;

  factory OrganizationView.fromJson(Map<String, dynamic> json) => _$OrganizationViewFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

