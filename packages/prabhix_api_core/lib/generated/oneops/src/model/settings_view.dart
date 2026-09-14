//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SettingsView {
  /// Returns a new [SettingsView] instance.
  SettingsView({

     this.availability,

     this.awayMessage,

     this.businessHours,

     this.preChatEnabled,

     this.offlineMailboxId,
  });

  @JsonKey(
    
    name: r'availability',
    required: false,
    includeIfNull: false,
  )


  final SettingsViewAvailabilityEnum? availability;



  @JsonKey(
    
    name: r'awayMessage',
    required: false,
    includeIfNull: false,
  )


  final String? awayMessage;



  @JsonKey(
    
    name: r'businessHours',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? businessHours;



  @JsonKey(
    
    name: r'preChatEnabled',
    required: false,
    includeIfNull: false,
  )


  final bool? preChatEnabled;



  @JsonKey(
    
    name: r'offlineMailboxId',
    required: false,
    includeIfNull: false,
  )


  final String? offlineMailboxId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SettingsView &&
      other.availability == availability &&
      other.awayMessage == awayMessage &&
      other.businessHours == businessHours &&
      other.preChatEnabled == preChatEnabled &&
      other.offlineMailboxId == offlineMailboxId;

    @override
    int get hashCode =>
        availability.hashCode +
        awayMessage.hashCode +
        businessHours.hashCode +
        preChatEnabled.hashCode +
        offlineMailboxId.hashCode;

  factory SettingsView.fromJson(Map<String, dynamic> json) => _$SettingsViewFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SettingsViewAvailabilityEnum {
@JsonValue(r'ONLINE')
ONLINE(r'ONLINE'),
@JsonValue(r'AWAY')
AWAY(r'AWAY'),
@JsonValue(r'OFFLINE')
OFFLINE(r'OFFLINE');

const SettingsViewAvailabilityEnum(this.value);

final String value;

@override
String toString() => value;
}


