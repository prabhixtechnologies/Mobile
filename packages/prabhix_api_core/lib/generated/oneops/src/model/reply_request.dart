//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reply_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplyRequest {
  /// Returns a new [ReplyRequest] instance.
  ReplyRequest({

    required  this.to,

     this.cc,

     this.subject,

    required  this.bodyHtml,
  });

  @JsonKey(
    
    name: r'to',
    required: true,
    includeIfNull: false,
  )


  final List<String> to;



  @JsonKey(
    
    name: r'cc',
    required: false,
    includeIfNull: false,
  )


  final List<String>? cc;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'bodyHtml',
    required: true,
    includeIfNull: false,
  )


  final String bodyHtml;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReplyRequest &&
      other.to == to &&
      other.cc == cc &&
      other.subject == subject &&
      other.bodyHtml == bodyHtml;

    @override
    int get hashCode =>
        to.hashCode +
        cc.hashCode +
        subject.hashCode +
        bodyHtml.hashCode;

  factory ReplyRequest.fromJson(Map<String, dynamic> json) => _$ReplyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReplyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

