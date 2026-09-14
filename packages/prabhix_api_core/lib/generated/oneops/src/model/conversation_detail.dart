//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/message_view.dart';
import 'package:prabhix_oneops_api/src/model/conversation_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConversationDetail {
  /// Returns a new [ConversationDetail] instance.
  ConversationDetail({

     this.conversation,

     this.messages,
  });

  @JsonKey(
    
    name: r'conversation',
    required: false,
    includeIfNull: false,
  )


  final ConversationSummary? conversation;



  @JsonKey(
    
    name: r'messages',
    required: false,
    includeIfNull: false,
  )


  final List<MessageView>? messages;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConversationDetail &&
      other.conversation == conversation &&
      other.messages == messages;

    @override
    int get hashCode =>
        conversation.hashCode +
        messages.hashCode;

  factory ConversationDetail.fromJson(Map<String, dynamic> json) => _$ConversationDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

