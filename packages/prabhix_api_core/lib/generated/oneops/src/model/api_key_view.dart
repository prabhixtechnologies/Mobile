//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_key_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiKeyView {
  /// Returns a new [ApiKeyView] instance.
  ApiKeyView({

     this.id,

     this.name,

     this.prefix,

     this.lastUsedAt,

     this.createdAt,

     this.expiresAt,
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
    
    name: r'prefix',
    required: false,
    includeIfNull: false,
  )


  final String? prefix;



  @JsonKey(
    
    name: r'lastUsedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastUsedAt;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(
    
    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApiKeyView &&
      other.id == id &&
      other.name == name &&
      other.prefix == prefix &&
      other.lastUsedAt == lastUsedAt &&
      other.createdAt == createdAt &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        prefix.hashCode +
        lastUsedAt.hashCode +
        createdAt.hashCode +
        expiresAt.hashCode;

  factory ApiKeyView.fromJson(Map<String, dynamic> json) => _$ApiKeyViewFromJson(json);

  Map<String, dynamic> toJson() => _$ApiKeyViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

