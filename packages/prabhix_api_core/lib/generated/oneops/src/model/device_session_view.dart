//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_session_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceSessionView {
  /// Returns a new [DeviceSessionView] instance.
  DeviceSessionView({

     this.id,

     this.deviceName,

     this.deviceType,

     this.ipAddress,

     this.lastSeenAt,

     this.createdAt,

     this.current,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'deviceName',
    required: false,
    includeIfNull: false,
  )


  final String? deviceName;



  @JsonKey(
    
    name: r'deviceType',
    required: false,
    includeIfNull: false,
  )


  final String? deviceType;



  @JsonKey(
    
    name: r'ipAddress',
    required: false,
    includeIfNull: false,
  )


  final String? ipAddress;



  @JsonKey(
    
    name: r'lastSeenAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSeenAt;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(
    
    name: r'current',
    required: false,
    includeIfNull: false,
  )


  final bool? current;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceSessionView &&
      other.id == id &&
      other.deviceName == deviceName &&
      other.deviceType == deviceType &&
      other.ipAddress == ipAddress &&
      other.lastSeenAt == lastSeenAt &&
      other.createdAt == createdAt &&
      other.current == current;

    @override
    int get hashCode =>
        id.hashCode +
        deviceName.hashCode +
        deviceType.hashCode +
        ipAddress.hashCode +
        lastSeenAt.hashCode +
        createdAt.hashCode +
        current.hashCode;

  factory DeviceSessionView.fromJson(Map<String, dynamic> json) => _$DeviceSessionViewFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceSessionViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

