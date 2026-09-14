//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/session_view.dart';
import 'package:prabhix_oneops_api/src/model/visitor_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'visitor_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VisitorDetail {
  /// Returns a new [VisitorDetail] instance.
  VisitorDetail({

     this.visitor,

     this.sessions,
  });

  @JsonKey(
    
    name: r'visitor',
    required: false,
    includeIfNull: false,
  )


  final VisitorSummary? visitor;



  @JsonKey(
    
    name: r'sessions',
    required: false,
    includeIfNull: false,
  )


  final List<SessionView>? sessions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VisitorDetail &&
      other.visitor == visitor &&
      other.sessions == sessions;

    @override
    int get hashCode =>
        visitor.hashCode +
        sessions.hashCode;

  factory VisitorDetail.fromJson(Map<String, dynamic> json) => _$VisitorDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VisitorDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

