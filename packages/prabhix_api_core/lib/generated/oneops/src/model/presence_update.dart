//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presence_update.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PresenceUpdate {
  /// Returns a new [PresenceUpdate] instance.
  PresenceUpdate({

    required  this.url,

    required  this.path,

     this.title,
  });

  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PresenceUpdate &&
      other.url == url &&
      other.path == path &&
      other.title == title;

    @override
    int get hashCode =>
        url.hashCode +
        path.hashCode +
        title.hashCode;

  factory PresenceUpdate.fromJson(Map<String, dynamic> json) => _$PresenceUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$PresenceUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

