//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/member_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cursor_page_member_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CursorPageMemberView {
  /// Returns a new [CursorPageMemberView] instance.
  CursorPageMemberView({

     this.items,

     this.nextCursor,

     this.hasMore,
  });

  @JsonKey(
    
    name: r'items',
    required: false,
    includeIfNull: false,
  )


  final List<MemberView>? items;



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
    bool operator ==(Object other) => identical(this, other) || other is CursorPageMemberView &&
      other.items == items &&
      other.nextCursor == nextCursor &&
      other.hasMore == hasMore;

    @override
    int get hashCode =>
        items.hashCode +
        nextCursor.hashCode +
        hasMore.hashCode;

  factory CursorPageMemberView.fromJson(Map<String, dynamic> json) => _$CursorPageMemberViewFromJson(json);

  Map<String, dynamic> toJson() => _$CursorPageMemberViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

