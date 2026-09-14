//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'canned_reply_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CannedReplyRequest {
  /// Returns a new [CannedReplyRequest] instance.
  CannedReplyRequest({

     this.shortcut,

    required  this.title,

    required  this.body,
  });

  @JsonKey(
    
    name: r'shortcut',
    required: false,
    includeIfNull: false,
  )


  final String? shortcut;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CannedReplyRequest &&
      other.shortcut == shortcut &&
      other.title == title &&
      other.body == body;

    @override
    int get hashCode =>
        shortcut.hashCode +
        title.hashCode +
        body.hashCode;

  factory CannedReplyRequest.fromJson(Map<String, dynamic> json) => _$CannedReplyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CannedReplyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

