//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'canned_reply_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CannedReplyView {
  /// Returns a new [CannedReplyView] instance.
  CannedReplyView({

     this.id,

     this.shortcut,

     this.title,

     this.body,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'shortcut',
    required: false,
    includeIfNull: false,
  )


  final String? shortcut;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CannedReplyView &&
      other.id == id &&
      other.shortcut == shortcut &&
      other.title == title &&
      other.body == body;

    @override
    int get hashCode =>
        id.hashCode +
        shortcut.hashCode +
        title.hashCode +
        body.hashCode;

  factory CannedReplyView.fromJson(Map<String, dynamic> json) => _$CannedReplyViewFromJson(json);

  Map<String, dynamic> toJson() => _$CannedReplyViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

