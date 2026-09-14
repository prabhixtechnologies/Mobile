//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NoteSummary {
  /// Returns a new [NoteSummary] instance.
  NoteSummary({

     this.id,

     this.authorUserId,

     this.bodyHtml,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'authorUserId',
    required: false,
    includeIfNull: false,
  )


  final String? authorUserId;



  @JsonKey(
    
    name: r'bodyHtml',
    required: false,
    includeIfNull: false,
  )


  final String? bodyHtml;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NoteSummary &&
      other.id == id &&
      other.authorUserId == authorUserId &&
      other.bodyHtml == bodyHtml &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        authorUserId.hashCode +
        bodyHtml.hashCode +
        createdAt.hashCode;

  factory NoteSummary.fromJson(Map<String, dynamic> json) => _$NoteSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$NoteSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

