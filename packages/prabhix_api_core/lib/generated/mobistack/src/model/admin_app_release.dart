//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_app_release.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAppRelease {
  /// Returns a new [AdminAppRelease] instance.
  AdminAppRelease({

     this.platform,

     this.minNativeBuild,

     this.latestNativeBuild,

     this.forceNativeUpdate,

     this.otaChannel,

     this.storeUrl,

     this.notes,
  });

  @JsonKey(
    
    name: r'platform',
    required: false,
    includeIfNull: false,
  )


  final String? platform;



  @JsonKey(
    
    name: r'minNativeBuild',
    required: false,
    includeIfNull: false,
  )


  final int? minNativeBuild;



  @JsonKey(
    
    name: r'latestNativeBuild',
    required: false,
    includeIfNull: false,
  )


  final int? latestNativeBuild;



  @JsonKey(
    
    name: r'forceNativeUpdate',
    required: false,
    includeIfNull: false,
  )


  final bool? forceNativeUpdate;



  @JsonKey(
    
    name: r'otaChannel',
    required: false,
    includeIfNull: false,
  )


  final String? otaChannel;



  @JsonKey(
    
    name: r'storeUrl',
    required: false,
    includeIfNull: false,
  )


  final String? storeUrl;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminAppRelease &&
      other.platform == platform &&
      other.minNativeBuild == minNativeBuild &&
      other.latestNativeBuild == latestNativeBuild &&
      other.forceNativeUpdate == forceNativeUpdate &&
      other.otaChannel == otaChannel &&
      other.storeUrl == storeUrl &&
      other.notes == notes;

    @override
    int get hashCode =>
        platform.hashCode +
        minNativeBuild.hashCode +
        latestNativeBuild.hashCode +
        forceNativeUpdate.hashCode +
        otaChannel.hashCode +
        storeUrl.hashCode +
        notes.hashCode;

  factory AdminAppRelease.fromJson(Map<String, dynamic> json) => _$AdminAppReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAppReleaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

