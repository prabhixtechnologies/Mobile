//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/session_context.dart';
import 'package:prabhix_oneops_api/src/model/page_view_input.dart';
import 'package:prabhix_oneops_api/src/model/presence_update.dart';
import 'package:prabhix_oneops_api/src/model/custom_event_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'batch_ingest_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BatchIngestRequest {
  /// Returns a new [BatchIngestRequest] instance.
  BatchIngestRequest({

     this.visitorKey,

     this.sessionId,

    required  this.consent,

     this.pageViews,

     this.events,

     this.session,

     this.utm,

     this.referrer,

     this.presence,
  });

  @JsonKey(
    
    name: r'visitorKey',
    required: false,
    includeIfNull: false,
  )


  final String? visitorKey;



  @JsonKey(
    
    name: r'sessionId',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;



  @JsonKey(
    
    name: r'consent',
    required: true,
    includeIfNull: false,
  )


  final BatchIngestRequestConsentEnum consent;



  @JsonKey(
    
    name: r'pageViews',
    required: false,
    includeIfNull: false,
  )


  final List<PageViewInput>? pageViews;



  @JsonKey(
    
    name: r'events',
    required: false,
    includeIfNull: false,
  )


  final List<CustomEventInput>? events;



  @JsonKey(
    
    name: r'session',
    required: false,
    includeIfNull: false,
  )


  final SessionContext? session;



  @JsonKey(
    
    name: r'utm',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? utm;



  @JsonKey(
    
    name: r'referrer',
    required: false,
    includeIfNull: false,
  )


  final String? referrer;



  @JsonKey(
    
    name: r'presence',
    required: false,
    includeIfNull: false,
  )


  final PresenceUpdate? presence;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BatchIngestRequest &&
      other.visitorKey == visitorKey &&
      other.sessionId == sessionId &&
      other.consent == consent &&
      other.pageViews == pageViews &&
      other.events == events &&
      other.session == session &&
      other.utm == utm &&
      other.referrer == referrer &&
      other.presence == presence;

    @override
    int get hashCode =>
        visitorKey.hashCode +
        sessionId.hashCode +
        consent.hashCode +
        pageViews.hashCode +
        events.hashCode +
        session.hashCode +
        utm.hashCode +
        referrer.hashCode +
        presence.hashCode;

  factory BatchIngestRequest.fromJson(Map<String, dynamic> json) => _$BatchIngestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BatchIngestRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum BatchIngestRequestConsentEnum {
@JsonValue(r'FULL')
FULL(r'FULL'),
@JsonValue(r'MINIMAL')
MINIMAL(r'MINIMAL'),
@JsonValue(r'DELETED')
DELETED(r'DELETED');

const BatchIngestRequestConsentEnum(this.value);

final String value;

@override
String toString() => value;
}


