//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_conversation_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartConversationResponse {
  /// Returns a new [StartConversationResponse] instance.
  StartConversationResponse({

     this.conversationId,

     this.conversationToken,

     this.status,

     this.agentsAvailable,
  });

  @JsonKey(
    
    name: r'conversationId',
    required: false,
    includeIfNull: false,
  )


  final String? conversationId;



  @JsonKey(
    
    name: r'conversationToken',
    required: false,
    includeIfNull: false,
  )


  final String? conversationToken;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final StartConversationResponseStatusEnum? status;



  @JsonKey(
    
    name: r'agentsAvailable',
    required: false,
    includeIfNull: false,
  )


  final bool? agentsAvailable;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StartConversationResponse &&
      other.conversationId == conversationId &&
      other.conversationToken == conversationToken &&
      other.status == status &&
      other.agentsAvailable == agentsAvailable;

    @override
    int get hashCode =>
        conversationId.hashCode +
        conversationToken.hashCode +
        status.hashCode +
        agentsAvailable.hashCode;

  factory StartConversationResponse.fromJson(Map<String, dynamic> json) => _$StartConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StartConversationResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum StartConversationResponseStatusEnum {
@JsonValue(r'OPEN')
OPEN(r'OPEN'),
@JsonValue(r'PENDING')
PENDING(r'PENDING'),
@JsonValue(r'RESOLVED')
RESOLVED(r'RESOLVED'),
@JsonValue(r'CLOSED')
CLOSED(r'CLOSED');

const StartConversationResponseStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


