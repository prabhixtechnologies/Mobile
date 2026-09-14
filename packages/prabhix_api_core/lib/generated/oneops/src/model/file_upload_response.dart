//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_upload_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FileUploadResponse {
  /// Returns a new [FileUploadResponse] instance.
  FileUploadResponse({

     this.id,

     this.filename,

     this.contentType,

     this.sizeBytes,

     this.scanStatus,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'filename',
    required: false,
    includeIfNull: false,
  )


  final String? filename;



  @JsonKey(
    
    name: r'contentType',
    required: false,
    includeIfNull: false,
  )


  final String? contentType;



  @JsonKey(
    
    name: r'sizeBytes',
    required: false,
    includeIfNull: false,
  )


  final int? sizeBytes;



  @JsonKey(
    
    name: r'scanStatus',
    required: false,
    includeIfNull: false,
  )


  final FileUploadResponseScanStatusEnum? scanStatus;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FileUploadResponse &&
      other.id == id &&
      other.filename == filename &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes &&
      other.scanStatus == scanStatus;

    @override
    int get hashCode =>
        id.hashCode +
        filename.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode +
        scanStatus.hashCode;

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) => _$FileUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum FileUploadResponseScanStatusEnum {
@JsonValue(r'PENDING')
PENDING(r'PENDING'),
@JsonValue(r'CLEAN')
CLEAN(r'CLEAN'),
@JsonValue(r'INFECTED')
INFECTED(r'INFECTED'),
@JsonValue(r'SKIPPED')
SKIPPED(r'SKIPPED');

const FileUploadResponseScanStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


