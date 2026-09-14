//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerSummary {
  /// Returns a new [CustomerSummary] instance.
  CustomerSummary({

     this.id,

     this.email,

     this.name,

     this.phone,

     this.marketingConsent,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'marketingConsent',
    required: false,
    includeIfNull: false,
  )


  final bool? marketingConsent;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerSummary &&
      other.id == id &&
      other.email == email &&
      other.name == name &&
      other.phone == phone &&
      other.marketingConsent == marketingConsent &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        name.hashCode +
        phone.hashCode +
        marketingConsent.hashCode +
        createdAt.hashCode;

  factory CustomerSummary.fromJson(Map<String, dynamic> json) => _$CustomerSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

