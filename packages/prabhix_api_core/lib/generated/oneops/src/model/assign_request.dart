//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assign_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssignRequest {
  /// Returns a new [AssignRequest] instance.
  AssignRequest({

     this.userId,

     this.teamId,
  });

  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



  @JsonKey(
    
    name: r'teamId',
    required: false,
    includeIfNull: false,
  )


  final String? teamId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssignRequest &&
      other.userId == userId &&
      other.teamId == teamId;

    @override
    int get hashCode =>
        userId.hashCode +
        teamId.hashCode;

  factory AssignRequest.fromJson(Map<String, dynamic> json) => _$AssignRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

