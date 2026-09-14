//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'canned_reply_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CannedReplyResponse {
  /// Returns a new [CannedReplyResponse] instance.
  CannedReplyResponse({

     this.id,

     this.mailboxId,

     this.shortcut,

     this.title,

     this.subject,

     this.bodyHtml,

     this.usageCount,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'mailboxId',
    required: false,
    includeIfNull: false,
  )


  final String? mailboxId;



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
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'bodyHtml',
    required: false,
    includeIfNull: false,
  )


  final String? bodyHtml;



  @JsonKey(
    
    name: r'usageCount',
    required: false,
    includeIfNull: false,
  )


  final int? usageCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CannedReplyResponse &&
      other.id == id &&
      other.mailboxId == mailboxId &&
      other.shortcut == shortcut &&
      other.title == title &&
      other.subject == subject &&
      other.bodyHtml == bodyHtml &&
      other.usageCount == usageCount;

    @override
    int get hashCode =>
        id.hashCode +
        mailboxId.hashCode +
        shortcut.hashCode +
        title.hashCode +
        subject.hashCode +
        bodyHtml.hashCode +
        usageCount.hashCode;

  factory CannedReplyResponse.fromJson(Map<String, dynamic> json) => _$CannedReplyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CannedReplyResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

