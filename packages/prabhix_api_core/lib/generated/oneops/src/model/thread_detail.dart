//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/message_summary.dart';
import 'package:prabhix_oneops_api/src/model/event_summary.dart';
import 'package:prabhix_oneops_api/src/model/thread_summary.dart';
import 'package:prabhix_oneops_api/src/model/note_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ThreadDetail {
  /// Returns a new [ThreadDetail] instance.
  ThreadDetail({

     this.thread,

     this.messages,

     this.notes,

     this.events,
  });

  @JsonKey(
    
    name: r'thread',
    required: false,
    includeIfNull: false,
  )


  final ThreadSummary? thread;



  @JsonKey(
    
    name: r'messages',
    required: false,
    includeIfNull: false,
  )


  final List<MessageSummary>? messages;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final List<NoteSummary>? notes;



  @JsonKey(
    
    name: r'events',
    required: false,
    includeIfNull: false,
  )


  final List<EventSummary>? events;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ThreadDetail &&
      other.thread == thread &&
      other.messages == messages &&
      other.notes == notes &&
      other.events == events;

    @override
    int get hashCode =>
        thread.hashCode +
        messages.hashCode +
        notes.hashCode +
        events.hashCode;

  factory ThreadDetail.fromJson(Map<String, dynamic> json) => _$ThreadDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

