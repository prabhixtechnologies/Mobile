//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_view_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageViewInput {
  /// Returns a new [PageViewInput] instance.
  PageViewInput({

    required  this.url,

    required  this.path,

     this.title,

     this.referrer,

     this.durationMs,

     this.entry,

     this.exit,
  });

  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'path',
    required: true,
    includeIfNull: false,
  )


  final String path;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'referrer',
    required: false,
    includeIfNull: false,
  )


  final String? referrer;



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
    bool operator ==(Object other) => identical(this, other) || other is PageViewInput &&
      other.url == url &&
      other.path == path &&
      other.title == title &&
      other.referrer == referrer &&
      other.durationMs == durationMs &&
      other.entry == entry &&
      other.exit == exit;

    @override
    int get hashCode =>
        url.hashCode +
        path.hashCode +
        title.hashCode +
        referrer.hashCode +
        durationMs.hashCode +
        entry.hashCode +
        exit.hashCode;

  factory PageViewInput.fromJson(Map<String, dynamic> json) => _$PageViewInputFromJson(json);

  Map<String, dynamic> toJson() => _$PageViewInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

