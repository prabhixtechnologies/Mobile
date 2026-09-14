//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_prefs_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPrefsRequest {
  /// Returns a new [NotificationPrefsRequest] instance.
  NotificationPrefsRequest({

     this.preferences,
  });

  @JsonKey(
    
    name: r'preferences',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? preferences;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NotificationPrefsRequest &&
      other.preferences == preferences;

    @override
    int get hashCode =>
        preferences.hashCode;

  factory NotificationPrefsRequest.fromJson(Map<String, dynamic> json) => _$NotificationPrefsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPrefsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

