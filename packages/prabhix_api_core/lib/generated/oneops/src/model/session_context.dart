//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_context.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionContext {
  /// Returns a new [SessionContext] instance.
  SessionContext({

     this.deviceType,

     this.browser,

     this.os,

     this.screenWidth,

     this.screenHeight,

     this.language,

     this.timezone,
  });

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
    
    name: r'screenWidth',
    required: false,
    includeIfNull: false,
  )


  final int? screenWidth;



  @JsonKey(
    
    name: r'screenHeight',
    required: false,
    includeIfNull: false,
  )


  final int? screenHeight;



  @JsonKey(
    
    name: r'language',
    required: false,
    includeIfNull: false,
  )


  final String? language;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SessionContext &&
      other.deviceType == deviceType &&
      other.browser == browser &&
      other.os == os &&
      other.screenWidth == screenWidth &&
      other.screenHeight == screenHeight &&
      other.language == language &&
      other.timezone == timezone;

    @override
    int get hashCode =>
        deviceType.hashCode +
        browser.hashCode +
        os.hashCode +
        screenWidth.hashCode +
        screenHeight.hashCode +
        language.hashCode +
        timezone.hashCode;

  factory SessionContext.fromJson(Map<String, dynamic> json) => _$SessionContextFromJson(json);

  Map<String, dynamic> toJson() => _$SessionContextToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

