//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_view_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageViewView {
  /// Returns a new [PageViewView] instance.
  PageViewView({

     this.id,

     this.url,

     this.path,

     this.title,

     this.viewedAt,

     this.durationMs,

     this.entry,

     this.exit,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'path',
    required: false,
    includeIfNull: false,
  )


  final String? path;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'viewedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? viewedAt;



  @JsonKey(
    
    name: r'durationMs',
    required: false,
    includeIfNull: false,
  )


  final int? durationMs;



  @JsonKey(
    
    name: r'entry',
    required: false,
    includeIfNull: false,
  )


  final bool? entry;



  @JsonKey(
    
    name: r'exit',
    required: false,
    includeIfNull: false,
  )


  final bool? exit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PageViewView &&
      other.id == id &&
      other.url == url &&
      other.path == path &&
      other.title == title &&
      other.viewedAt == viewedAt &&
      other.durationMs == durationMs &&
      other.entry == entry &&
      other.exit == exit;

    @override
    int get hashCode =>
        id.hashCode +
        url.hashCode +
        path.hashCode +
        title.hashCode +
        viewedAt.hashCode +
        durationMs.hashCode +
        entry.hashCode +
        exit.hashCode;

  factory PageViewView.fromJson(Map<String, dynamic> json) => _$PageViewViewFromJson(json);

  Map<String, dynamic> toJson() => _$PageViewViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

