//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_visitor.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LiveVisitor {
  /// Returns a new [LiveVisitor] instance.
  LiveVisitor({

     this.visitorId,

     this.externalKey,

     this.currentPath,

     this.currentTitle,

     this.since,

     this.email,

     this.displayName,
  });

  @JsonKey(
    
    name: r'visitorId',
    required: false,
    includeIfNull: false,
  )


  final String? visitorId;



  @JsonKey(
    
    name: r'externalKey',
    required: false,
    includeIfNull: false,
  )


  final String? externalKey;



  @JsonKey(
    
    name: r'currentPath',
    required: false,
    includeIfNull: false,
  )


  final String? currentPath;



  @JsonKey(
    
    name: r'currentTitle',
    required: false,
    includeIfNull: false,
  )


  final String? currentTitle;



  @JsonKey(
    
    name: r'since',
    required: false,
    includeIfNull: false,
  )


  final DateTime? since;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LiveVisitor &&
      other.visitorId == visitorId &&
      other.externalKey == externalKey &&
      other.currentPath == currentPath &&
      other.currentTitle == currentTitle &&
      other.since == since &&
      other.email == email &&
      other.displayName == displayName;

    @override
    int get hashCode =>
        visitorId.hashCode +
        externalKey.hashCode +
        currentPath.hashCode +
        currentTitle.hashCode +
        since.hashCode +
        email.hashCode +
        displayName.hashCode;

  factory LiveVisitor.fromJson(Map<String, dynamic> json) => _$LiveVisitorFromJson(json);

  Map<String, dynamic> toJson() => _$LiveVisitorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

