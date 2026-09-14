//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ProductStatus {
      @JsonValue(r'DRAFT')
      DRAFT(r'DRAFT'),
      @JsonValue(r'ACTIVE')
      ACTIVE(r'ACTIVE'),
      @JsonValue(r'ARCHIVED')
      ARCHIVED(r'ARCHIVED');

  const ProductStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
