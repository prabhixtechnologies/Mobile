//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/thread_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cursor_page_thread_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CursorPageThreadSummary {
  /// Returns a new [CursorPageThreadSummary] instance.
  CursorPageThreadSummary({

     this.items,

     this.nextCursor,

     this.hasMore,
  });

  @JsonKey(
    
    name: r'items',
    required: false,
    includeIfNull: false,
  )


  final List<ThreadSummary>? items;



  @JsonKey(
    
    name: r'nextCursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;



  @JsonKey(
    
    name: r'hasMore',
    required: false,
    includeIfNull: false,
  )


  final bool? hasMore;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CursorPageThreadSummary &&
      other.items == items &&
      other.nextCursor == nextCursor &&
      other.hasMore == hasMore;

    @override
    int get hashCode =>
        items.hashCode +
        nextCursor.hashCode +
        hasMore.hashCode;

  factory CursorPageThreadSummary.fromJson(Map<String, dynamic> json) => _$CursorPageThreadSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CursorPageThreadSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

