//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inbox_counts.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InboxCounts {
  /// Returns a new [InboxCounts] instance.
  InboxCounts({

     this.unassigned,

     this.mineUnread,
  });

  @JsonKey(
    
    name: r'unassigned',
    required: false,
    includeIfNull: false,
  )


  final int? unassigned;



  @JsonKey(
    
    name: r'mineUnread',
    required: false,
    includeIfNull: false,
  )


  final int? mineUnread;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InboxCounts &&
      other.unassigned == unassigned &&
      other.mineUnread == mineUnread;

    @override
    int get hashCode =>
        unassigned.hashCode +
        mineUnread.hashCode;

  factory InboxCounts.fromJson(Map<String, dynamic> json) => _$InboxCountsFromJson(json);

  Map<String, dynamic> toJson() => _$InboxCountsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

