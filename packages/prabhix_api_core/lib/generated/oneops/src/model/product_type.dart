//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ProductType {
      @JsonValue(r'SUBSCRIPTION')
      SUBSCRIPTION(r'SUBSCRIPTION'),
      @JsonValue(r'DIGITAL')
      DIGITAL(r'DIGITAL'),
      @JsonValue(r'SERVICE')
      SERVICE(r'SERVICE'),
      @JsonValue(r'PHYSICAL')
      PHYSICAL(r'PHYSICAL');

  const ProductType(this.value);

  final String value;

  @override
  String toString() => value;
}
