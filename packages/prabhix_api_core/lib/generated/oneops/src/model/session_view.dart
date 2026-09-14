//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionView {
  /// Returns a new [SessionView] instance.
  SessionView({

     this.id,

     this.startedAt,

     this.endedAt,

     this.durationSeconds,

     this.entryUrl,

     this.exitUrl,

     this.referrer,

     this.deviceType,

     this.browser,

     this.os,

     this.geoCountry,

     this.geoCity,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'startedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startedAt;



  @JsonKey(
    
    name: r'endedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endedAt;



  @JsonKey(
    
    name: r'durationSeconds',
    required: false,
    includeIfNull: false,
  )


  final int? durationSeconds;



  @JsonKey(
    
    name: r'entryUrl',
    required: false,
    includeIfNull: false,
  )


  final String? entryUrl;



  @JsonKey(
    
    name: r'exitUrl',
    required: false,
    includeIfNull: false,
  )


  final String? exitUrl;



  @JsonKey(
    
    name: r'referrer',
    required: false,
    includeIfNull: false,
  )


  final String? referrer;



  @JsonKey(
    
    name: r'deviceType',
    required: false,
    includeIfNull: false,
  )


  final String? deviceType;



  @JsonKey(
    
    name: r'browser',
    required: false,
    includeIfNull: false,
  )


  final String? browser;



  @JsonKey(
    
    name: r'os',
    required: false,
    includeIfNull: false,
  )


  final String? os;



  @JsonKey(
    
    name: r'geoCountry',
    required: false,
    includeIfNull: false,
  )


  final String? geoCountry;



  @JsonKey(
    
    name: r'geoCity',
    required: false,
    includeIfNull: false,
  )


  final String? geoCity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionView &&
      other.id == id &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.durationSeconds == durationSeconds &&
      other.entryUrl == entryUrl &&
      other.exitUrl == exitUrl &&
      other.referrer == referrer &&
      other.deviceType == deviceType &&
      other.browser == browser &&
      other.os == os &&
      other.geoCountry == geoCountry &&
      other.geoCity == geoCity;

    @override
    int get hashCode =>
        id.hashCode +
        startedAt.hashCode +
        endedAt.hashCode +
        durationSeconds.hashCode +
        entryUrl.hashCode +
        exitUrl.hashCode +
        referrer.hashCode +
        deviceType.hashCode +
        browser.hashCode +
        os.hashCode +
        geoCountry.hashCode +
        geoCity.hashCode;

  factory SessionView.fromJson(Map<String, dynamic> json) => _$SessionViewFromJson(json);

  Map<String, dynamic> toJson() => _$SessionViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

