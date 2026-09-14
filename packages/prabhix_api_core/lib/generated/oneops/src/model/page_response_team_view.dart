//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/team_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_response_team_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageResponseTeamView {
  /// Returns a new [PageResponseTeamView] instance.
  PageResponseTeamView({

     this.items,

     this.page,

     this.size,

     this.totalItems,

     this.totalPages,

     this.hasNext,

     this.hasPrevious,
  });

  @JsonKey(
    
    name: r'items',
    required: false,
    includeIfNull: false,
  )


  final List<TeamView>? items;



  @JsonKey(
    
    name: r'page',
    required: false,
    includeIfNull: false,
  )


  final int? page;



  @JsonKey(
    
    name: r'size',
    required: false,
    includeIfNull: false,
  )


  final int? size;



  @JsonKey(
    
    name: r'totalItems',
    required: false,
    includeIfNull: false,
  )


  final int? totalItems;



  @JsonKey(
    
    name: r'totalPages',
    required: false,
    includeIfNull: false,
  )


  final int? totalPages;



  @JsonKey(
    
    name: r'hasNext',
    required: false,
    includeIfNull: false,
  )


  final bool? hasNext;



  @JsonKey(
    
    name: r'hasPrevious',
    required: false,
    includeIfNull: false,
  )


  final bool? hasPrevious;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PageResponseTeamView &&
      other.items == items &&
      other.page == page &&
      other.size == size &&
      other.totalItems == totalItems &&
      other.totalPages == totalPages &&
      other.hasNext == hasNext &&
      other.hasPrevious == hasPrevious;

    @override
    int get hashCode =>
        items.hashCode +
        page.hashCode +
        size.hashCode +
        totalItems.hashCode +
        totalPages.hashCode +
        hasNext.hashCode +
        hasPrevious.hashCode;

  factory PageResponseTeamView.fromJson(Map<String, dynamic> json) => _$PageResponseTeamViewFromJson(json);

  Map<String, dynamic> toJson() => _$PageResponseTeamViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

